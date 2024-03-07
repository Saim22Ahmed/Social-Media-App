import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:word_wall/components/comment.dart';
import 'package:word_wall/components/comment_button.dart';
import 'package:word_wall/components/delete_button.dart';
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
    required this.time,
    this.commentsCount,
  });

  final String message;
  final String user;
  final String postId;
  final String time;
  final List<String> likes;
  final dynamic commentsCount;

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
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text('Add Comment'),
            content: TextField(
              cursorColor: Colors.grey[500],
              controller: commentTextController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Write a comment..',
                hintStyle: TextStyle(color: Colors.grey[300]),
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
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary),
                ),
              ),

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
                  child: Text('POST',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onTertiary))),
            ],
          );
        });
  }

  // delete post
  void deletePost() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(),
              title: Text('Delete Post'),
              content: Text('Are you sure you want to delete this post?'),
              actions: [
                //Cancel button
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onTertiary),
                    )),

                //Delete button
                TextButton(
                    onPressed: () async {
                      // delete comment first from firestore

                      final commentDocs = await FirebaseFirestore.instance
                          .collection('User Posts')
                          .doc(widget.postId)
                          .collection('Comments')
                          .get();

                      for (var doc in commentDocs.docs) {
                        doc.reference.delete();
                      }

                      // delete the post

                      await FirebaseFirestore.instance
                          .collection('User Posts')
                          .doc(widget.postId)
                          .delete()
                          .then((value) => ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                duration: 900.ms,
                                backgroundColor:
                                    Theme.of(context).colorScheme.onTertiary,
                                dismissDirection: DismissDirection.horizontal,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 15.w, vertical: 15.h),
                                content: Text('Post Deleted'),
                              )))
                          .catchError(
                              (error) => print("Failed to delete: $error"));

                      // pop the dialog box
                      Navigator.pop(context);
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
      margin: EdgeInsets.only(top: 25.h, left: 25.w, right: 25.w),
      padding: EdgeInsets.all(25.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // post

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // message and user
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // message

                Text(widget.message),
                5.h.verticalSpace,

                // user

                Row(children: [
                  Text(
                    widget.user,
                    style: TextStyle(color: Colors.grey[500]),
                  ),

                  10.h.horizontalSpace,

                  // time

                  Text(
                    widget.time,
                    style: TextStyle(color: Colors.grey[500]),
                  )
                ]),
              ],
            ),

            // delelte button
            if (widget.user == currentUser.email)
              DeleteButton(onTap: deletePost),
          ],
        ),
        //

        22.h.verticalSpace,
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
                Text(widget.commentsCount.toString())
              ],
            ),
          ],
        ),

        20.h.verticalSpace,

        // comments under the post

        // StreamBuilder(
        //     stream: FirebaseFirestore.instance
        //         .collection('User Posts')
        //         .doc(widget.postId)
        //         .collection('Comments')
        //         .orderBy('time', descending: true)
        //         .snapshots(),
        //     builder: (context, snapshot) {
        //       if (!snapshot.hasData) {
        //         return Center(
        //             child: CircularProgressIndicator(
        //                 color: Theme.of(context).colorScheme.primary));
        //       } else {
        //         return ListView(
        //             shrinkWrap: true,
        //             physics: const NeverScrollableScrollPhysics(),
        //             children: snapshot.data!.docs.map((doc) {
        //               final commentData = doc.data() as Map<String, dynamic>;
        //               return Comment(
        //                 comment: commentData['Comment'],
        //                 user: commentData['By'],
        //                 time: FormatedTime(
        //                   commentData['time'],
        //                 ),
        //                 date: FormatedDate(commentData['time']),
        //               );
        //             }).toList());
        //       }
        //     })
        StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('User Posts')
                .doc(widget.postId)
                .collection('Comments')
                .orderBy('time', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final commentData = snapshot.data!.docs[index];
                      return Comment(
                        comment: commentData['Comment'],
                        user: commentData['By'],
                        time: FormatedTime(
                          commentData['time'],
                        ),
                        date: FormatedDate(commentData['time']),
                      );
                    });
              } else if (snapshot.hasError) {
                return Center(
                    child: Text(
                  snapshot.error.toString(),
                ));
              }

              return Center(
                child: Container(),
              );
            })
      ]),
    );
  }
}
