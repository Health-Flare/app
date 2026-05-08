import 'package:flutter/material.dart';

import 'package:health_flare/features/shell/widgets/profile_icon_button.dart';

/// App-wide AppBar that always places [ProfileIconButton] as the rightmost
/// action, ensuring no screen can accidentally obscure or omit the profile
/// icon.
///
/// Usage is identical to [AppBar]: pass [title], any screen-specific
/// [actions], and an optional [bottom] (e.g. a [TabBar]).  The profile icon
/// is appended automatically — do not add it manually.
class HFAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HFAppBar({
    super.key,
    this.title,
    this.actions,
    this.bottom,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: [...?actions, const ProfileIconButton()],
      bottom: bottom,
    );
  }
}
