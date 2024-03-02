import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:word_wall/components/like_button.dart';
import 'package:word_wall/constants.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 25.h, left: 25.w, right: 25.w),
      padding: EdgeInsets.all(26.w),
      decoration: BoxDecoration(
        border: Border.all(width: 0.5, color: themecolor),
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
      child: Row(children: [
        // Like Button
        Column(
          children: [
            LikeButton(
              isLiked: isLiked,
              onTap: toggleLike,
            ),
            5.h.verticalSpace,
            Text(widget.likes.length.toString())
          ],
        ),

        20.w.horizontalSpace,
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            widget.user,
            style: TextStyle(color: Colors.grey[500]),
          ),
          10.h.verticalSpace,
          Text(widget.message),
        ])
      ]),
    );
  }
}
