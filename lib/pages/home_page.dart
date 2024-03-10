import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:word_wall/components/myTextFormFields.dart';
import 'package:word_wall/components/my_drawer.dart';
import 'package:word_wall/components/post.dart';
import 'package:word_wall/constants.dart';
import 'package:word_wall/helper/helper_methods.dart';
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

  void postmessage() async {
    // if text field is not empty
    if (textController.text.isNotEmpty) {
      // show loading circle
      showDialog(
          context: context,
          builder: (context) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          });

      // fetching user name
      final userData = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.email)
          .get();

      final username = userData.data()!['username'];

      // add post in firestore
      FirebaseFirestore.instance.collection('User Posts').add({
        'Message': textController.text,
        'UserEmail': currentUser.email,
        'TimeStamp': Timestamp.now(),
        'username': username,
        'Likes': [],
      });

      // pop loading circle

      Navigator.pop(context);

      // clear the textfield

      textController.clear();
    }
  }

  void goToProfilePage() {
    Get.back();
    Get.to(() => ProfilePage(), transition: Transition.fadeIn);
  }

  void ScrollToTop() {
    return WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      // Scroll to the bottom of the list after new data is loaded
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: signOut,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Word Wall',
        ),
      ),
      body: Center(
        child: Column(children: [
          // newsfeed
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('User Posts')
                      .orderBy('TimeStamp', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        reverse: true,
                        shrinkWrap: true,
                        controller: scrollController,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          // get the message
                          final post = snapshot.data!.docs[index];

                          return Post(
                            message: post['Message'],
                            user: post['username'],
                            userEmail: post['UserEmail'],
                            postId: post.id,
                            likes: List<String>.from(post['Likes'] ?? []),
                            time: FormatedDate(post['TimeStamp']),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    }
                    return Center(
                        child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ));
                  }),
            ),
          ),

          // post message field
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: PostMessageField(
                    textController: textController,
                    onTap: () {},
                  ),
                ),
                IconButton(
                    onPressed: () {
                      postmessage();
                    },
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                    ))
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
                color: Theme.of(context).colorScheme.tertiary,
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
  PostMessageField({
    super.key,
    required this.textController,
    required this.onTap,
  });

  final TextEditingController textController;
  final void Function()? onTap;

  @override
  State<PostMessageField> createState() => _PostMessageFieldState();
}

class _PostMessageFieldState extends State<PostMessageField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Theme.of(context).colorScheme.onTertiary,
      onTap: widget.onTap,
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
        fillColor: Theme.of(context).colorScheme.primary,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(4.r),
        ),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
          width: 1.w,
        )),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onTertiary,
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
