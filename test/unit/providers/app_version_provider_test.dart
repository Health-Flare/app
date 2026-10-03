import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/app_version_provider.dart';

void main() {
  group('formatAppVersion', () {
    test('shows version and build number', () {
      expect(formatAppVersion('1.2.1', '5'), '1.2.1 (build 5)');
    });

    test('omits an empty build number', () {
      expect(formatAppVersion('1.2.1', ''), '1.2.1');
    });

    test('says Unknown when the platform reports no version', () {
      expect(formatAppVersion('', ''), 'Unknown');
    });
  });
}
