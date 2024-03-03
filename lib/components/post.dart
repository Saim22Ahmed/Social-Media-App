import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:word_wall/components/comment.dart';
import 'package:word_wall/components/comment_button.dart';
import 'package:word_wall/components/like_button.dart';
import 'package:word_wall/constants.dart';
import 'package:word_wall/helper/helper_methods.dart';

class Post extends StatefulWidget {
  Post({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
  });

  final String message;
  final String user;
  final String postId;
  final List<String> likes;

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  bool isLiked = false;

  // commenttextController
  final commentTextController = TextEditingController();

  @override
  void initState() {
    isLiked = widget.likes.contains(currentUser.email);
    // TODO: implement initState
    super.initState();
  }

  // toggle like
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    // storing the likes into the firebase

    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      // if post is liked , it will add the users email to the likes field array in firebase
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      // if post is not liked , it will remove the users email from the likes field array in firebase
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  // add a comment

  void addComment(String comment) {
    // write comment to firestore under the comments collection inside the user posts

    FirebaseFirestore.instance
        .collection('User Posts')
        .doc(widget.postId)
        .collection('Comments')
        .add({
      'Comment': comment,
      'By': currentUser.email,
      'time': Timestamp.now()
    });
  }

  // display a dialog to add a comment

  void displayCommentDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Add Comment'),
            content: TextField(
              cursorColor: Colors.grey[500],
              controller: commentTextController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Write a comment..',
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
              autofocus: true,
            ),

            // actions

            actions: [
              // cancel button

              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    commentTextController.clear();
                  },
                  child: Text(
                    'CANCEL',
                    style: TextStyle(color: themecolor),
                  )),

              // post button

              TextButton(
                  onPressed: () {
                    // add the comment

                    addComment(
                      (commentTextController.text),
                    );

                    // pop and clear controller

                    Navigator.pop(context);
                    commentTextController.clear();
                  },
                  child: Text('POST', style: TextStyle(color: themecolor))),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 25.h, left: 25.w, right: 25.w),
      padding: EdgeInsets.all(26.w),
      decoration: BoxDecoration(
        // border: Border.all(width: 0.5, color: themecolor),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // post

        // message

        Text(widget.message),
        5.h.verticalSpace,

        // user

        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            widget.user,
            style: TextStyle(color: Colors.grey[500]),
          ),

          //

          20.h.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Like Button

              Column(
                children: [
                  LikeButton(
                    isLiked: isLiked,
                    onTap: toggleLike,
                  ),
                  5.h.verticalSpace,

                  // likes count

                  Text(widget.likes.length.toString())
                ],
              ),

              // Comment Button

              Column(
                children: [
                  CommentButton(
                    onTap: displayCommentDialog,
                  ),
                  5.h.verticalSpace,

                  // comment Count
                  Text('0')
                ],
              ),
            ],
          ),

          10.h.verticalSpace,

          // comments under the post

          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('User Posts')
                  .doc(widget.postId)
                  .collection('Comments')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(color: themecolor));
                } else {
                  return ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: snapshot.data!.docs.map((doc) {
                        return Comment(
                          comment: doc['Comment'],
                          user: doc['By'],
                          time: FormatedTime(
                            doc['time'],
                          ),
                          date: FormatedDate(doc['time']),
                        );
                      }).toList());
                }
              })
        ])
      ]),
    );
  }
}
