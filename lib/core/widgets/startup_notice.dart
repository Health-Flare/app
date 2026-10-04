import 'package:flutter/material.dart';

/// Shows a one-off startup message (e.g. a skipped or failed data upgrade)
/// in a [MaterialBanner] that stays until the user taps OK.
///
/// Uses the app's root [ScaffoldMessengerState] via [messengerKey], so the
/// banner sits above whichever screen the router shows first and survives
/// navigation.
class StartupNotice extends StatefulWidget {
  const StartupNotice({
    super.key,
    required this.notice,
    required this.messengerKey,
    required this.child,
  });

  /// The message, or null to show nothing.
  final String? notice;
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final Widget child;

  @override
  State<StartupNotice> createState() => _StartupNoticeState();
}

class _StartupNoticeState extends State<StartupNotice> {
  @override
  void initState() {
    super.initState();
    final notice = widget.notice;
    if (notice == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = widget.messengerKey.currentState;
      if (messenger == null) return;
      messenger.showMaterialBanner(
        MaterialBanner(
          content: Text(notice),
          leading: const Icon(Icons.info_outline),
          actions: [
            TextButton(
              onPressed: messenger.hideCurrentMaterialBanner,
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
