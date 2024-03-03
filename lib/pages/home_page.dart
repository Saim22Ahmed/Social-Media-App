import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:word_wall/components/myTextFormFields.dart';
import 'package:word_wall/components/my_drawer.dart';
import 'package:word_wall/components/post.dart';
import 'package:word_wall/constants.dart';
import 'package:word_wall/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  // text controller
  final textController = TextEditingController();

  // scroll controller
  ScrollController scrollController = ScrollController();

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void postmessage() {
    // if text field is not empty
    if (textController.text.isNotEmpty) {
      // add post in firestore
      FirebaseFirestore.instance.collection('User Posts').add({
        'Message': textController.text,
        'UserEmail': currentUser.email,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
      setState(() {
        // clear the text field
        textController.clear();
        // scroll to the top
        // scrollController.animateTo(
        //   scrollController.position.minScrollExtent,
        //   duration: Duration(seconds: 1),
        //   curve: Curves.fastOutSlowIn,
        // );
      });
    }
  }

  void goToProfilePage() {
    Get.back();
    Get.to(() => ProfilePage(), transition: Transition.rightToLeftWithFade);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: signOut,
      ),
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: themecolor,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Word Wall',
        ),
      ),
      body: Center(
        child: Column(children: [
          // newsfeed
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('User Posts')
                    .orderBy('TimeStamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      physics: BouncingScrollPhysics(),
                      controller: scrollController,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        // get the message
                        final post = snapshot.data!.docs[index];
                        return Post(
                            message: post['Message'],
                            user: post['UserEmail'],
                            postId: post.id,
                            likes: List<String>.from(post['Likes'] ?? []));
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }
                  return Center(
                      child: CircularProgressIndicator(
                    color: themecolor,
                  ));
                }),
          ),

          // post message field
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: PostMessageField(textController: textController),
                ),
                IconButton(onPressed: postmessage, icon: Icon(Icons.send))
              ],
            ),
          ),
          // current user email
          Padding(
            padding: EdgeInsets.only(bottom: 15.h),
            child: Container(
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: themecolor,
              ),
              child: Text('Logged in as ' + currentUser.email!,
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }
}

class PostMessageField extends StatefulWidget {
  const PostMessageField({
    super.key,
    required this.textController,
  });

  final TextEditingController textController;

  @override
  State<PostMessageField> createState() => _PostMessageFieldState();
}

class _PostMessageFieldState extends State<PostMessageField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(
        // height: 1.h,
        fontSize: 16.sp,
      ),
      controller: widget.textController,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 15.w),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(4.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: themecolor,
            width: 1.w,
          ),
          borderRadius: BorderRadius.circular(4.r),
        ),
        hintText: 'Write your thoughts..',
        hintStyle: TextStyle(
          fontSize: 16.sp,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
