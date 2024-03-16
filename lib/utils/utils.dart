import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:word_wall/constants.dart';

class Utils {
  static void CustomSnackBar(context,
      {color,
      required String text,
      IconData? icon,
      String? subtitle,
      duration}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: duration,
      backgroundColor: color ?? themecolor,
      dismissDirection: DismissDirection.horizontal,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 25.h),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(color: Colors.white),
              ),
              8.h.horizontalSpace,
              Container(
                margin: EdgeInsets.only(bottom: 5.h),
                child: Icon(
                  icon,
                  size: 24.sp,
                  color: Colors.white,
                ).animate().fade(duration: 300.ms).scaleXY(begin: 0, end: 1.0),
              )
            ],
          ),
          5.h.verticalSpace,
          Text(
            subtitle!,
          )
        ],
      ),
    ));
  }

  static void OneLineCustomSnackBar(context,
      {color, required String text, IconData? icon, duration}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: duration,
      backgroundColor: color ?? themecolor,
      dismissDirection: DismissDirection.horizontal,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 25.h),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          8.h.horizontalSpace,
          Container(
            margin: EdgeInsets.only(bottom: 5.h),
            child: Icon(
              icon,
              size: 24.sp,
              color: Colors.white,
            ).animate().fade(duration: 300.ms).scaleXY(begin: 0, end: 1.0),
          )
        ],
      ),
    ));
  }
}
