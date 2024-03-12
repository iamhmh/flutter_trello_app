import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Color(0xfff57b51),
        centerTitle: true,
        title: Container(
          height: 80,
          child: Image.asset('assets/images/logo.png'),
        ),
      );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}