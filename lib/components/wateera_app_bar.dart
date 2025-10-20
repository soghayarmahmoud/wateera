import 'package:flutter/material.dart';

class WateeraAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;

  const WateeraAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
