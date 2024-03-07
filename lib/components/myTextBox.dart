import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyTextBox extends StatelessWidget {
  MyTextBox(
      {super.key,
      required this.sectionName,
      required this.text,
      required this.onPressed});

  final String sectionName;
  final String text;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20.w, bottom: 20.h),
      margin: EdgeInsets.only(top: 20.w, left: 20.w, right: 20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //section name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(sectionName,
                  style: TextStyle(
                    color: Colors.grey[500],
                  )),

              // button
              IconButton(
                  onPressed: onPressed,
                  icon: Icon(
                    Icons.settings,
                    // size: 20.sp,
                    color: Colors.grey[500],
                  )),
            ],
          ),
          10.h.verticalSpace,
          //text
          Text(text),
        ],
      ),
    );
  }
}
