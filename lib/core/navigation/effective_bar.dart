import 'package:flutter/widgets.dart';

// TODO(#143): stubs.
const moreId = 'more';
const moreLocation = '/more';
const likeBeforePreset = [
  'dashboard',
  'track',
  'care.medications',
  'track.meals',
];
const likeBeforeNote = 'The old bar had six items. Sleep is now in Track.';

class BarSlot {
  const BarSlot({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.moreIds = const [],
  });
  final String id;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final List<String> moreIds;
}

List<BarSlot> effectiveBar(
  List<String> ids, {
  required bool Function(String id) shown,
  List<String>? fallback,
}) => throw UnimplementedError('#143');

String? selectedSlotId(List<BarSlot> slots, Uri location) =>
    throw UnimplementedError('#143');

bool canAdd(List<String> ids, String id) => throw UnimplementedError('#143');

bool canRemove(List<String> ids) => throw UnimplementedError('#143');

String? barLimitNote(List<String> ids) => throw UnimplementedError('#143');

String moveAnnouncement(String label, int position, int of) =>
    throw UnimplementedError('#143');
