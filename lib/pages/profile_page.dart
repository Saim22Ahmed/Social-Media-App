import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:word_wall/components/myTextBox.dart';
import 'package:word_wall/components/post.dart';
import 'package:word_wall/constants.dart';
import 'package:word_wall/helper/helper_methods.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final currentUser = FirebaseAuth.instance.currentUser!;
  final Users = FirebaseFirestore.instance.collection('Users');
  final UserPosts = FirebaseFirestore.instance.collection('User Posts');

  // edit field
  Future<void> editField(String field, BuildContext context) async {
    String newValue = '';
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.primary,
              title: Text(
                'Edit $field',
              ),
              content: TextField(
                  cursorColor: Colors.grey[500],
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter new $field',
                    hintStyle: TextStyle(color: Colors.grey[300]),
                  ),
                  autofocus: true,
                  onChanged: (value) {
                    newValue = value;
                  }),
              // actions
              actions: [
                // cancel
                TextButton(
                    child: Text('Cancel',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onTertiary)),
                    onPressed: () => Navigator.of(context).pop()),

                // save
                TextButton(
                    child: Text('Save',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onTertiary)),
                    onPressed: () {
                      Navigator.of(context).pop(newValue);
                    }),
              ]);
        });

    // updating in the firestore

    if (newValue != '') {
      // show the circular progress
      showDialog(
          context: context,
          builder: (context) => Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ));
      //updating in the userposts collection database also

      // Check if username already exists
      if (field == 'username') {
        QuerySnapshot usernameSnapshot =
            await UserPosts.where('username', isEqualTo: newValue).get();

        if (usernameSnapshot.docs.isNotEmpty) {
          // Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red[600],
            dismissDirection: DismissDirection.horizontal,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
            content: Text(
              'Username already exists. Please choose a different one.',
              style: TextStyle(color: Colors.white),
            ),
          ));
          if (context.mounted) Navigator.pop(context);
          return;
        }

        // pop the loader
        if (context.mounted) Navigator.pop(context);

        // update in the Users collection when there is soemthing on the textfield
        await Users.doc(currentUser.email).update({field: newValue});

        // updating in the User Posts Collection database

        // Query 'User Posts' collection for documents with current user's email
        var userPostsQuerySnapshot =
            await UserPosts.where('UserEmail', isEqualTo: currentUser.email)
                .get();

        // Iterate through each document and update the 'username' field
        userPostsQuerySnapshot.docs.forEach((postDoc) async {
          await postDoc.reference.update({'username': newValue});
        });

        // updating int the Comments collection

        userPostsQuerySnapshot.docs.forEach((postDoc) async {
          await postDoc.reference
              .collection('Comments')
              .where('UserEmail', isEqualTo: currentUser.email)
              .get()
              .then((value) {
            value.docs.forEach((commentDoc) async {
              await commentDoc.reference.update({'By': newValue});
            });
          });
        });

        // Query 'Comments' collection for documents with current user's email
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Profile'),
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(currentUser.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final userData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      return ListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            //profile pic
                            50.h.verticalSpace,
                            Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.tertiary,
                              size: 70.sp,
                            ),

                            SizedBox(height: 10.h),
                            //user email

                            Center(
                              child: Text(
                                currentUser.email!,
                                // style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),

                            SizedBox(height: 50.h),

                            //user details
                            Padding(
                              padding: EdgeInsets.only(left: 25.0.w),
                              child: Text('My Details',
                                  style: TextStyle(color: Colors.grey[600])),
                            ),

                            //user name
                            MyTextBox(
                              sectionName: 'username',
                              text: userData['username'],
                              onPressed: () => editField('username', context),
                            ),

                            //bio
                            MyTextBox(
                              sectionName: 'bio',
                              text: userData['bio'],
                              onPressed: () => editField('bio', context),
                            ),

                            SizedBox(height: 50.h),
                          ]);
                    }
                    // on Error
                    else if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    }
                    // On Loading
                    else {
                      return Center(
                          child: CircularProgressIndicator(
                        color: themecolor,
                      ));
                    }
                  }),

              SizedBox(height: 15.h),

              //user posts

              Padding(
                padding: EdgeInsets.only(left: 25.0.w),
                child:
                    Text('My Posts', style: TextStyle(color: Colors.grey[600])),
              ),

              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('User Posts')
                      .where('UserEmail', isEqualTo: currentUser.email)
                      // .orderBy('TimeStamp', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          // get the message
                          final post = snapshot.data!.docs[index];
                          return Post(
                            message: post['Message'],
                            userEmail: post['UserEmail'],
                            user: post['username'],
                            postId: post.id,
                            likes: List<String>.from(post['Likes'] ?? []),
                            time: FormatedDate(post['TimeStamp']),
                            imageUrl: post['Image'],
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
              20.h.verticalSpace,
            ],
          ),
        ));
  }
}
