import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Comment extends StatelessWidget {
  const Comment(
      {super.key,
      required this.comment,
      required this.user,
      required this.time,
      required this.date});

  final String comment;
  final String user;
  final String time;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // comment

        Text(comment),

        5.h.verticalSpace,

        // user

        Row(children: [
          Text(
            user,
            style: TextStyle(color: Colors.grey[600]),
          )
        ]),

        // Date and Time

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //Date

            Text(
              date,
              style: TextStyle(color: Colors.grey[500]),
            ),

            //Time

            Text(
              time,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        )
      ]),
    );
  }
}
