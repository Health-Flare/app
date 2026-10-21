// #105: an avatar is shown only from the app's own photos folder.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/files/photo_store.dart';
import 'package:health_flare/features/profiles/widgets/profile_avatar.dart';
import 'package:health_flare/models/profile.dart';

void main() {
  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('hf_avatar_');
    PhotoStore.init(root.path);
  });

  tearDown(() {
    PhotoStore.reset();
    root.deleteSync(recursive: true);
  });

  testWidgets('a path anywhere else shows initials, not the file', (
    tester,
  ) async {
    final elsewhere = File('${root.path}/secret.jpg')
      ..writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0]);
    await tester.pumpWidget(
      MaterialApp(
        home: ProfileAvatar(
          profile: Profile(
            id: 1,
            name: 'Sarah Chen',
            avatarPath: elsewhere.path,
          ),
        ),
      ),
    );
    expect(find.text('SC'), findsOneWidget);
    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundImage, isNull);
  });

  testWidgets('a picked image is previewed before it is saved', (tester) async {
    final picked = File('${root.path}/image_picker_1.jpg')
      ..writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0]);
    await tester.pumpWidget(
      MaterialApp(
        home: ProfileAvatar(
          profile: Profile(id: 1, name: 'Sarah Chen'),
          previewFile: picked,
        ),
      ),
    );
    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundImage, isA<FileImage>());
  });
}
