import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/shell/widgets/profile_icon_button.dart';

/// App-wide AppBar that always ends with a Settings button followed by
/// [ProfileIconButton] as the rightmost action, so no screen can
/// accidentally obscure or omit either.
///
/// Usage is identical to [AppBar]: pass [title], any screen-specific
/// [actions], and an optional [bottom] (e.g. a [TabBar]). The Settings
/// button and profile icon are appended automatically: do not add them
/// manually. Only the Settings screen itself sets [showSettingsButton] to
/// false, since the button would lead nowhere there.
class HFAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HFAppBar({
    super.key,
    this.title,
    this.actions,
    this.bottom,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.showSettingsButton = true,
  });

  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool showSettingsButton;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: [
        ...?actions,
        if (showSettingsButton) const SettingsIconButton(),
        const ProfileIconButton(),
      ],
      bottom: bottom,
    );
  }
}

/// Opens the app-level Settings screen. Placed by [HFAppBar] immediately to
/// the left of the profile icon on every screen except Settings itself.
class SettingsIconButton extends StatelessWidget {
  const SettingsIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings_outlined),
      tooltip: 'Settings',
      onPressed: () => context.push(AppRoutes.settings),
    );
  }
}
