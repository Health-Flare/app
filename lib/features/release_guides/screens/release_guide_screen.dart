import 'package:flutter/material.dart';

// TODO(#145)
class ReleaseGuideScreen extends StatelessWidget {
  const ReleaseGuideScreen({
    super.key,
    required this.guideId,
    this.initialStep = 0,
    this.replay = false,
  });

  final String guideId;
  final int initialStep;
  final bool replay;

  @override
  Widget build(BuildContext context) => const Scaffold();
}
