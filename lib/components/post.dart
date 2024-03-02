import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:word_wall/components/like_button.dart';
import 'package:word_wall/constants.dart';

class Post extends StatelessWidget {
  const Post({
    super.key,
    required this.message,
    required this.user,
  });

  final String message;
  final String user;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 25.h, left: 25.w, right: 25.w),
      padding: EdgeInsets.all(26.w),
      decoration: BoxDecoration(
        border: Border.all(width: 0.5, color: themecolor),
        // boxShadow: [
        //   BoxShadow(
        //       color: Colors.deepOrange.shade200,
        //       blurRadius: 2,
        //       spreadRadius: 0,
        //       offset: Offset(2, 2))
        // ],
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.white,
      ),
      child: Row(children: [
        // Like Button
        LikeButton(
          isLiked: true,
          onTap: () {},
        ),

        20.w.horizontalSpace,
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user),
          Text(message),
        ])
      ]),
    );
  }
}
