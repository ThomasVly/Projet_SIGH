import 'package:flutter/material.dart';

class SettingsHeader extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final String imagePath;

  const SettingsHeader({
    Key? key,
    this.height = 80,
    this.imagePath = 'assets/images/Header_general.jpg',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: height,
      titleSpacing: 0,
      leadingWidth: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
