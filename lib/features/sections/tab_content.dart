import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

class AddTarget {
  const AddTarget(this.location, {this.extra});
  final String location;
  final Object? extra;
}

class TabContent {
  const TabContent({
    required this.body,
    required this.addTooltip,
    required this.addTarget,
    this.addIcon = Icons.add,
  });

  final WidgetBuilder body;
  final String addTooltip;
  final IconData addIcon;
  final ProviderListenable<AddTarget> addTarget;
}

// TODO(#141): real bodies.
final tabContentProvider = Provider<Map<String, TabContent>>((ref) => {});
