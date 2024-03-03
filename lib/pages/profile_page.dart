import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:word_wall/components/myTextBox.dart';
import 'package:word_wall/constants.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final currentUser = FirebaseAuth.instance.currentUser!;
  final Users = FirebaseFirestore.instance.collection('Users');

  // edit field
  Future<void> editField(String field, BuildContext context) async {
    String newValue = '';
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              backgroundColor: themecolor,
              title: Text(
                'Edit $field',
                style: TextStyle(color: Colors.white),
              ),
              content: TextField(
                  style: TextStyle(color: Colors.white),
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
                // save
                TextButton(
                    child:
                        Text('Cancel', style: TextStyle(color: Colors.white)),
                    onPressed: () => Navigator.of(context).pop()),

                // cancel
                TextButton(
                    child: Text('Save', style: TextStyle(color: Colors.white)),
                    onPressed: () => Navigator.of(context).pop(newValue)),
              ]);
        });

    // updating in the firestore
    if (newValue != '') {
      // update when there is soemthing on the textfield
      await Users.doc(currentUser.email).update({field: newValue});
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
          title: Text('Profile'),
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(currentUser.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                return ListView(children: [
                  //profile pic
                  50.h.verticalSpace,
                  Icon(
                    Icons.person,
                    color: themecolor,
                    size: 70.sp,
                  ),

                  SizedBox(height: 10.h),
                  //user email

                  Center(
                    child: Text(
                      currentUser.email!,
                      style: TextStyle(color: Colors.grey[700]),
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

                  //user posts

                  Padding(
                    padding: EdgeInsets.only(left: 25.0.w),
                    child: Text('My Posts',
                        style: TextStyle(color: Colors.grey[600])),
                  ),
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
            }));
  }
}
