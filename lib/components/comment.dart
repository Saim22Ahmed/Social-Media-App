import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:word_wall/components/delete_button.dart';

class Comment extends StatefulWidget {
  Comment(
      {super.key,
      required this.comment,
      required this.user,
      required this.time,
      required this.date,
      required this.userEmail,
      required this.commentId,
      required this.postId});

  final String comment;
  final String user;
  final String userEmail;
  final String time;
  final String date;
  final String commentId;
  final String postId;

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final List<Color> userColors = [];

  // current user
  final currentUser = FirebaseAuth.instance.currentUser;

  // delete comment
  void deleteComment() async {
    //show dialog
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(
                'Delete Comment?',
              ),
              content: Text(
                'Are you sure you want to delete this comment?',
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onTertiary),
                    )),

                // delete button
                TextButton(
                    onPressed: () async {
                      showDialog(
                          context: context,
                          builder: (context) => Center(
                                  child: CircularProgressIndicator(
                                color: Colors.white,
                              )));
                      try {
                        var snapshot = await FirebaseFirestore.instance
                            .collection('User Posts')
                            .doc(widget.postId)
                            .collection('Comments')
                            .doc(widget.commentId)
                            .get();
                        await snapshot.reference.delete();

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: 900.ms,
                          backgroundColor: Color(0xff00B4D8),
                          dismissDirection: DismissDirection.horizontal,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.symmetric(
                              horizontal: 15.w, vertical: 25.h),
                          content: Row(
                            children: [
                              Text(
                                'Post Deleted',
                                style: TextStyle(color: Colors.white),
                              ),
                              10.h.horizontalSpace,
                              Icon(
                                Icons.check,
                                size: 24.sp,
                                color: Colors.white,
                              )
                                  .animate()
                                  .fade(duration: 300.ms)
                                  .scaleXY(begin: 0, end: 1.0)
                            ],
                          ),
                        ));
                        Navigator.pop(context);
                      } catch (e) {
                        log(e.toString());
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Delete',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onTertiary))),
              ]);
        });
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

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(widget.user,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 17.sp,
              )),

          // Delete Button
          if (widget.userEmail == currentUser!.email)
            DeleteButton(onTap: deleteComment),
        ]),
        5.h.verticalSpace,
        // comment

        Text(
          widget.comment,
        ),

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
