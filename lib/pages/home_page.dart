import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:word_wall/components/myTextFormFields.dart';
import 'package:word_wall/components/post.dart';
import 'package:word_wall/constants.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  // text controller
  final textController = TextEditingController();

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
      });
      setState(() {
        textController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: themecolor,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Word Wall',
        ),
        actions: [IconButton(onPressed: signOut, icon: Icon(Icons.logout))],
      ),
      body: Center(
        child: Column(children: [
          // newsfeed
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('User Posts')
                    .orderBy('TimeStamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        // get the message
                        final post = snapshot.data!.docs[index];
                        return Post(
                            message: post['Message'], user: post['UserEmail']);
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
            padding: const EdgeInsets.all(25.0),
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
          Text('Logged in as ' + currentUser.email!,
              style: TextStyle(color: Colors.grey[800])),
        ]),
      ),
    );
  }
}

class PostMessageField extends StatelessWidget {
  const PostMessageField({
    super.key,
    required this.textController,
  });

  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(
        // height: 1.h,
        fontSize: 16.sp,
      ),
      controller: textController,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
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
