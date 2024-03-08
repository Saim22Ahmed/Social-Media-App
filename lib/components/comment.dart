import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Comment extends StatefulWidget {
  Comment(
      {super.key,
      required this.comment,
      required this.user,
      required this.time,
      required this.date,
      required this.userEmail});

  final String comment;
  final String user;
  final String userEmail;
  final String time;
  final String date;

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final List<Color> userColors = [];

  Color getRandomColor() {
    final Random random = Random();
    return userColors[random.nextInt(userColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // user

        Row(children: [
          Text(
            widget.user,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontWeight: FontWeight.bold),
          )
        ]),
        5.h.verticalSpace,
        // comment

        Text(widget.comment),

        // Date and Time

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //Date

            Text(
              widget.date,
              style: TextStyle(color: Colors.grey[500]),
            ),

            //Time

            Text(
              widget.time,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        )
      ]),
    );
  }
}
