import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:word_wall/components/comment.dart';
import 'package:word_wall/components/comment_button.dart';
import 'package:word_wall/components/delete_button.dart';
import 'package:word_wall/components/edit_button.dart';
import 'package:word_wall/components/like_button.dart';
import 'package:word_wall/constants.dart';
import 'package:word_wall/helper/helper_methods.dart';
import 'package:http/http.dart' as http;

class Post extends StatefulWidget {
  Post({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
    required this.userEmail,
    this.imageUrl,
  });

  final String message;
  final String user;
  final String userEmail;
  final String postId;
  final String time;
  final List<String> likes;
  final String? imageUrl;

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  bool isLiked = false;

  // commenttextController
  final commentTextController = TextEditingController();

  // edit post text field controller
  final editPostTextController = TextEditingController();

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

  void addComment(String comment) async {
    // write comment to firestore under the comments collection inside the user posts

    // fetching the username
    // Fetch the current user's data from the Users collection
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.email)
        .get();

    final username = userSnapshot['username'];

    // add comment to firebase

    FirebaseFirestore.instance
        .collection('User Posts')
        .doc(widget.postId)
        .collection('Comments')
        .add({
      'Comment': comment,
      'By': username,
      'time': Timestamp.now(),
      'UserEmail': currentUser.email
    });

    SendNotificationToPostOwner(comment, username);
  }

// delete comment

  void SendNotificationToPostOwner(comment, username) async {
    // Fetch the post owner's user token from Firestore
    DocumentSnapshot postOwnerSnapshot = await FirebaseFirestore.instance
        .collection('User Posts')
        .doc(widget.postId)
        .get();
    var postOwnerEmail = postOwnerSnapshot['UserEmail'];

    // fetching postowner device token
    final postOwnerToken = await FirebaseFirestore.instance
        .collection('Users')
        .doc(postOwnerEmail)
        .get()
        .then((value) => value['device token']);

    log('Post Owner Token: $postOwnerToken');

    // Construct the FCM notification message
    try {
      var message = {
        'to': postOwnerToken,
        'priority': 'high',
        'notification': {
          'title': '$username commented on your post',
          'body': '$username: $comment',
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
        }
      };

      // Send the message to the post owner's device
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAAr2uLlVY:APA91bGrDo-ixGSqaNwspdFc0XzbZXqS43Meyk3gwfqOq6dYYv9H1PWK4X1sbLC-DGb4ZUs___1jsvOUXix63VDB2ngzx6QLSSGdjJC9z9Gy6tiS5XTMjn6rSSrLi1SR1AkZ2zcpJr0G',
        },
        body: jsonEncode(message),
      );
    } catch (e) {
      print('Error sending FCM notification: $e');
    }
    ;
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
                    // show circular progress indicator
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Center(
                              child: CircularProgressIndicator(
                            color: Colors.white,
                          ));
                        });
                    // add the comment

                    addComment(
                      (commentTextController.text),
                    );

                    // pop the dialog
                    if (context.mounted) {
                      Navigator.pop(context);
                    }

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

                      // show circular progress indicator
                      showDialog(
                          context: context,
                          builder: (context) => Center(
                                  child: CircularProgressIndicator(
                                color: Colors.white,
                              )));

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
                          .then((value) {
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
                      });
                      // pop the dialog box
                      Navigator.pop(context);

                      // delete the image from firebase storage also

                      await FirebaseStorage.instance
                          .refFromURL(widget.imageUrl!)
                          .delete();
                    },
                    child: Text('Delete',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onTertiary))),
              ]);
        });
  }

  // edit post
  void editPost() {
    editPostTextController.text = widget.message;

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(),
            title: Text('Edit Post'),
            content: TextField(
              maxLines: null,
              cursorColor: Colors.grey[500],
              controller: editPostTextController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'write a post',
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
                    editPostTextController.clear();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiary),
                  )),

              //Save Button
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                    // update the post

                    updatePost();

                    // clear controller

                    editPostTextController.clear();
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiary),
                  )),
            ],
          );
        });
  }

  void updatePost() async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
              child: CircularProgressIndicator(
            color: Colors.white,
          ));
        });

    if (editPostTextController.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('User Posts')
          .doc(widget.postId)
          .update({'Message': editPostTextController.text});

      if (context.mounted) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: 900.ms,
        backgroundColor: Color(0xff00B4D8),
        dismissDirection: DismissDirection.horizontal,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 25.h),
        content: Row(
          children: [
            Text(
              'Post Updated successfully',
              style: TextStyle(color: Colors.white),
            ),
            10.h.horizontalSpace,
            Icon(
              Icons.check,
              size: 24.sp,
            ).animate().fade(duration: 300.ms).scaleXY(begin: 0, end: 1.0)
          ],
        ),
      ));
    } else {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: 900.ms,
            backgroundColor: Colors.red,
            dismissDirection: DismissDirection.horizontal,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 25.h),
            content: Row(children: [
              Text(
                'Post cannot be empty',
                style: TextStyle(color: Colors.white),
              )
            ])));
      }
    }
  }

  Future<int> commentsCount() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('User Posts')
        .doc(widget.postId)
        .collection('Comments')
        .get();

    return querySnapshot.docs.length;
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
            // user and message
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // user

                Row(children: [
                  Text(
                    widget.user + '.',
                    style: TextStyle(
                      // color: Color(0xff00B4D8),

                      color: Theme.of(context).colorScheme.inversePrimary,
                      // fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.righteous().fontFamily,
                      fontSize: 20.sp,
                    ),
                  ),

                  // time
                ]),
                Text(
                  widget.time,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 15.sp,
                  ),
                )
              ],
            ),

            // edit and delete button

            Row(
              children: [
                // edit button
                if (widget.userEmail == currentUser.email)
                  EditButton(onTap: editPost),

                20.h.horizontalSpace,
                // delelte button
                if (widget.userEmail == currentUser.email)
                  DeleteButton(onTap: deletePost),
              ],
            )
          ],
        ),

        15.h.verticalSpace,
        //

        // message

        Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Text(
              widget.message,
              softWrap: true,
              style: TextStyle(fontSize: 17.sp),
            )),
        18.h.verticalSpace,

        // Image

        if (widget.imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(18.r),
            child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: widget.imageUrl!,
                maxHeightDiskCache: 300,
                placeholder: (context, url) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.r),
                      color: Theme.of(context).hintColor,
                    ),
                    height: 300.h,
                    width: double.infinity,
                  )
                      .animate(
                        onPlay: (controller) => controller.repeat(),
                      )
                      .shimmer(
                        curve: Curves.easeOut,
                        duration: 1600.ms,
                        color: Theme.of(context).shadowColor,
                      );
                }),
          ),

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
                FutureBuilder<int>(
                  future: commentsCount(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text('0');
                    }
                    return Text(snapshot.data.toString());
                  },
                )
              ],
            ),
          ],
        ),

        20.h.verticalSpace,

        // comments under the post

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
                      // if comments are less and equal to 2

                      final commentData = snapshot.data!.docs[index];

                      return Comment(
                        comment: commentData['Comment'],
                        commentId: commentData.id,
                        postId: widget.postId,
                        user: commentData['By'],
                        userEmail: commentData['UserEmail'],
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
              } else if (!snapshot.hasData) {
                return Container();
              }

              return Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.r),
                    color: Theme.of(context).hintColor,
                  ),
                  height: 100.h,
                  width: double.infinity,
                )
                    .animate(
                      onPlay: (controller) => controller.repeat(),
                    )
                    .shimmer(
                      curve: Curves.easeOut,
                      duration: 1600.ms,
                      color: Theme.of(context).shadowColor,
                    ),
              );
            })
      ]),
    );
  }
}
