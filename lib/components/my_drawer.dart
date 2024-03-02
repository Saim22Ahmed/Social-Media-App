import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:word_wall/components/my_ListTile.dart';
import 'package:word_wall/constants.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer(
      {super.key, required this.onProfileTap, required this.onSignOut});

  final void Function() onProfileTap;
  final void Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color.fromARGB(255, 182, 99, 26),
      child: Column(
        children: [
          // header
          Theme(
            data: Theme.of(context).copyWith(
                dividerTheme: DividerThemeData(color: Colors.transparent)),
            child: DrawerHeader(
                child: Icon(
              Icons.motion_photos_on,
              color: Colors.white,
              size: 64.sp,
            )),
          ),

          // home
          MyListTile(
            onTap: () => Get.back(),
            icon: Icons.home,
            title: 'H O M E',
          ),

          // home
          MyListTile(
            onTap: onProfileTap,
            icon: Icons.person,
            title: 'P R O F I L E',
          ),
          // logout
          MyListTile(
            onTap: onSignOut,
            icon: BoxIcons.bx_log_out,
            title: 'L O G O U T',
          ),
        ],
      ),
    );
  }
}
