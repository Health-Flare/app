import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// File extension for password-encrypted Health Flare backups (see
/// docs/features/encrypted-backup.feature). Distinct from the plain ".isar"
/// backups [BackupService.export] produces, so a person looking at their
/// files can tell the two apart. The app itself never relies on the
/// extension: [EncryptedBackupCodec.isEncrypted] checks the file's content.
abstract final class EncryptedBackupFormat {
  static const extension = '.hfbackup';
}

/// Thrown by [EncryptedBackupCodec.decryptFile] when a `.hfbackup` file
/// can't be decrypted: either the password was wrong, or the file is
/// corrupted or has been tampered with. Authenticated encryption can't tell
/// those two cases apart by design, so callers show one generic "incorrect
/// password" message for both (see "A corrupted or tampered backup cannot
/// be distinguished from a wrong password" in
/// docs/features/encrypted-backup.feature).
class BackupEncryptionException implements Exception {
  const BackupEncryptionException(this.message);

  final String message;

  @override
  String toString() => 'BackupEncryptionException: $message';
}

/// Encrypts and decrypts Health Flare backup files with a user-supplied
/// password. Used by [BackupService.exportEncrypted] on export, and by the
/// import flow to unlock a `.hfbackup` file into a plain, decrypted temp
/// copy before handing it to the existing [ImportService]/[BackupService]
/// restore paths, which need no changes of their own to support encrypted
/// backups.
///
/// ## File format
///
/// ```
/// [8-byte magic "HFBKUP01"][16-byte salt][12-byte nonce][16-byte MAC][ciphertext]
/// ```
///
/// The magic and salt (the header) are not secret, but they are passed to
/// AES-GCM as associated data, so altering them fails authentication just
/// like altering the ciphertext does. Only the password (never written
/// anywhere) and the key derived from it are secret. A fresh salt and nonce
/// are generated on every [encryptFile] call, so encrypting identical content
/// with the same password twice produces different output.
///
/// The trailing `01` in the magic is the format version. A future variant
/// (for example an anonymized export) gets its own magic rather than
/// reinterpreting this one.
///
/// ## Cryptography
///
/// - Key derivation: Argon2id, memory-hard so brute-forcing the password
///   can't be cheaply parallelized on GPUs/ASICs. Parameters (19 MiB
///   memory, 2 iterations, 1 lane) follow OWASP's minimum recommendation
///   for Argon2id.
/// - Encryption: AES-256-GCM, authenticated, so decryption fails loudly on
///   any tampering instead of silently returning corrupted plaintext.
///
/// Both come from `package:cryptography`, a vetted, actively maintained
/// implementation; nothing here hand-rolls a cryptographic primitive.
/// Key derivation and encryption run on a background isolate
/// ([Isolate.run]) so the UI doesn't freeze while Argon2id works.
class EncryptedBackupCodec {
  EncryptedBackupCodec._();

  static final Uint8List _magicBytes = Uint8List.fromList(
    utf8.encode('HFBKUP01'),
  );
  static const _saltLength = 16;
  static const _nonceLength = 12;
  static const _macLength = 16;
  static const _headerLength = 8 /* magic */ + _saltLength;
  static const _minFileLength = _headerLength + _nonceLength + _macLength;

  static const _notABackupMessage =
      'This file is not a Health Flare encrypted backup.';
  static const _wrongPasswordMessage =
      'Incorrect password, or the file is damaged.';

  static AesGcm _cipher() => AesGcm.with256bits(nonceLength: _nonceLength);

  static Argon2id _kdf() => Argon2id(
    parallelism: 1,
    memory: 19456, // ~19 MiB: OWASP-recommended Argon2id minimum.
    iterations: 2,
    hashLength: 32, // 256-bit key, matching AesGcm.with256bits().
  );

  /// Returns true if the file at [path] looks like an encrypted Health
  /// Flare backup, based on its header. Doesn't require the password and
  /// doesn't verify the content; only [decryptFile] does that.
  static Future<bool> isEncrypted(String path) async {
    final file = File(path);
    if (!await file.exists()) return false;
    if (await file.length() < _headerLength) return false;

    final raf = await file.open();
    try {
      final header = await raf.read(_magicBytes.length);
      return _bytesEqual(header, _magicBytes);
    } finally {
      await raf.close();
    }
  }

  /// Reads the plaintext file at [plainPath], encrypts it with [password],
  /// and writes the result to [outPath]. Returns [outPath].
  static Future<String> encryptFile({
    required String plainPath,
    required String outPath,
    required String password,
  }) async {
    final plainBytes = await File(plainPath).readAsBytes();
    final encrypted = await Isolate.run(
      () => _encryptBytes(plainBytes, password),
    );
    await File(outPath).writeAsBytes(encrypted, flush: true);
    return outPath;
  }

  /// Decrypts [encryptedPath] with [password] into a new file at [outPath].
  /// Returns [outPath]. Nothing is written to [outPath] unless decryption
  /// and authentication both succeed.
  ///
  /// Throws [BackupEncryptionException] if [encryptedPath] isn't a Health
  /// Flare encrypted backup, or if the password is wrong, or the file is
  /// corrupted/tampered with. The latter two are indistinguishable by
  /// design (see the class doc).
  static Future<String> decryptFile({
    required String encryptedPath,
    required String outPath,
    required String password,
  }) async {
    final bytes = await File(encryptedPath).readAsBytes();
    if (bytes.length < _headerLength ||
        !_bytesEqual(bytes.sublist(0, _magicBytes.length), _magicBytes)) {
      throw const BackupEncryptionException(_notABackupMessage);
    }

    final plainBytes = await Isolate.run(() => _decryptBytes(bytes, password));
    if (plainBytes == null) {
      throw const BackupEncryptionException(_wrongPasswordMessage);
    }

    await File(outPath).writeAsBytes(plainBytes, flush: true);
    return outPath;
  }

  // ── Isolate bodies ────────────────────────────────────────────────────────
  //
  // Top-level-safe static functions: they capture only their arguments, so
  // Isolate.run can send them to a background isolate.

  static Future<Uint8List> _encryptBytes(
    Uint8List plainBytes,
    String password,
  ) async {
    final salt = _randomBytes(_saltLength);
    final header = Uint8List.fromList([..._magicBytes, ...salt]);

    final secretKey = await _kdf().deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    final secretBox = await _cipher().encrypt(
      plainBytes,
      secretKey: secretKey,
      aad: header,
    );

    return (BytesBuilder(copy: false)
          ..add(header)
          ..add(secretBox.nonce)
          ..add(secretBox.mac.bytes)
          ..add(secretBox.cipherText))
        .toBytes();
  }

  /// Returns the plaintext, or null if authentication failed (wrong password
  /// or a damaged/tampered file).
  static Future<List<int>?> _decryptBytes(
    Uint8List bytes,
    String password,
  ) async {
    if (bytes.length < _minFileLength) return null;

    final header = Uint8List.sublistView(bytes, 0, _headerLength);
    final salt = Uint8List.sublistView(
      bytes,
      _magicBytes.length,
      _headerLength,
    );
    var offset = _headerLength;
    final nonce = Uint8List.sublistView(bytes, offset, offset + _nonceLength);
    offset += _nonceLength;
    final mac = Uint8List.sublistView(bytes, offset, offset + _macLength);
    offset += _macLength;
    final cipherText = Uint8List.sublistView(bytes, offset);

    final secretKey = await _kdf().deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );

    try {
      return await _cipher().decrypt(
        SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
        secretKey: secretKey,
        aad: header,
      );
    } on SecretBoxAuthenticationError {
      return null;
    }
  }

  static Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  static bool _bytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
