import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// TODO(#141)
Page<void> sectionPage(GoRouterState state) =>
    MaterialPage(key: state.pageKey, child: const SizedBox.shrink());
