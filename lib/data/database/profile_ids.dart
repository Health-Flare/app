import 'dart:math';

import 'package:isar_community/isar.dart';

import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/profile_deletion.dart';
import 'package:health_flare/data/models/profile_isar.dart';

/// Reserves and returns a profile id that has never been used on this
/// device.
///
/// Isar's own auto-increment restarts from the highest id still stored each
/// time the database opens, so deleting the newest profile and restarting
/// handed its id to the next new profile, along with any rows still linked
/// to it (#117). This counter only goes up.
///
/// Must be called inside an `isar.writeTxn`, in the same transaction that
/// puts the profile, so a failed write doesn't burn or reuse an id.
Future<int> nextProfileId(Isar isar) async {
  final settings = await isar.appSettings.get(1) ?? AppSettings();
  final next = max(settings.lastProfileId, await _maxStoredId(isar)) + 1;
  settings.lastProfileId = next;
  await isar.appSettings.put(settings);
  return next;
}

/// The highest profile id in use anywhere: on a profile, or on any entry
/// still pointing at a deleted one. Seeds [AppSettings.lastProfileId] when
/// upgrading to v19. Must be called inside an `isar.writeTxn`.
Future<int> highestProfileIdInUse(Isar isar) async {
  final referenced = await referencedProfileIds(isar);
  return referenced.fold<int>(await _maxStoredId(isar), max);
}

/// Highest id on a stored profile, or 0. Computed in Dart: Isar's
/// `idProperty().max()` returns null for the `Id` property. A device holds
/// a handful of profiles, so reading every id is cheap.
Future<int> _maxStoredId(Isar isar) async {
  final ids = await isar.profileIsars.where().idProperty().findAll();
  return ids.fold<int>(0, max);
}
