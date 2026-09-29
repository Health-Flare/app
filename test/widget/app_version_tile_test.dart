import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:health_flare/features/settings/widgets/app_version_tile.dart';

void main() {
  testWidgets('shows the installed version and build number', (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'Test',
      packageName: 'org.example.test',
      version: '9.8.7',
      buildNumber: '42',
      buildSignature: '',
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: AppVersionTile())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('App version'), findsOneWidget);
    expect(find.text('9.8.7 (build 42)'), findsOneWidget);
  });
}
