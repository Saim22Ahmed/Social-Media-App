import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Comment extends StatefulWidget {
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
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
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
        // comment

        Text(widget.comment),

        5.h.verticalSpace,

        // user

        Row(children: [
          Text(
            widget.user,
            style: TextStyle(color: Colors.grey[600]),
          )
        ]),

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
