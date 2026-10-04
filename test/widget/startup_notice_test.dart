import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/widgets/startup_notice.dart';

// A skipped or failed upgrade is told to the user on the first screen
// (#110, docs/features/datastore.feature).

void main() {
  Widget app(String? notice) {
    final key = GlobalKey<ScaffoldMessengerState>();
    return MaterialApp(
      scaffoldMessengerKey: key,
      home: StartupNotice(
        notice: notice,
        messengerKey: key,
        child: const Scaffold(body: Text('home')),
      ),
    );
  }

  testWidgets('shows the notice in a banner until dismissed', (tester) async {
    await tester.pumpWidget(app('Your data is unchanged.'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(MaterialBanner), findsOneWidget);
    expect(find.text('Your data is unchanged.'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(MaterialBanner), findsNothing);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('shows nothing when there is no notice', (tester) async {
    await tester.pumpWidget(app(null));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(MaterialBanner), findsNothing);
    expect(find.text('home'), findsOneWidget);
  });
}
