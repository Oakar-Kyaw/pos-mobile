import 'package:flutter/material.dart';
import 'package:pos/utils/font-size.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onMenuPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.leading,
    this.actions,
    this.onMenuPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: AppBar(
        leading: leading,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: FontSizeConfig.title(context),
          ),
        ),
        centerTitle: true,
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
