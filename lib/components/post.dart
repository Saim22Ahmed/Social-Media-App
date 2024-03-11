import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:word_wall/components/comment.dart';
import 'package:word_wall/components/comment_button.dart';
import 'package:word_wall/components/delete_button.dart';
import 'package:word_wall/components/edit_button.dart';
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
                      color: Color(0xff00B4D8),
                      fontWeight: FontWeight.bold,
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
            width: MediaQuery.of(context).size.width * 0.65,
            child: Text(
              widget.message,
              softWrap: true,
              style: TextStyle(fontSize: 17.sp),
            )),
        18.h.verticalSpace,

        // Image

        if (widget.imageUrl != null)
          // CachedNetworkImage(
          //   imageUrl: widget.imageUrl!,
          //   placeholder: (context, url) {
          //     return Center(
          //       child: Container(
          //         color: Colors.white,
          //       ),
          //     );
          //   },
          // ),
          ClipRRect(
            borderRadius: BorderRadius.circular(18.r),
            child: Container(
              decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(9.r),
                  ),
              child: Image.network(
                widget.imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Container(
                    color: Colors.white,
                  ).animate().shimmer();
                },
              ),
            ),
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
                      // final commentscount = snapshot.data!.docs.length;
                      return Comment(
                        comment: commentData['Comment'],
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
              }

              return Center(
                child: Container(),
              );
            })
      ]),
    );
  }
}
