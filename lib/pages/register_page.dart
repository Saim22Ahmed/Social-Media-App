import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:word_wall/components/myTextFormFields.dart';
import 'package:word_wall/components/mybutton.dart';
import 'package:word_wall/constants.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  RegisterPage({
    super.key,
    required this.onTap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final email_controller = TextEditingController();
  final password_controller = TextEditingController();
  final confirm_password_controller = TextEditingController();

  void signUp(context) async {
    // show loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        });

    if (password_controller.text != confirm_password_controller.text) {
      Navigator.pop(context);
      displayMessage('Password do not Match', context);
      return;
    }

    // try creating the user
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email_controller.text, password: password_controller.text);

      // after user created , create a new document for the user in firestore

      FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.email)
          .set({
        'username': email_controller.text
            .split('@')[0], //inital username (saim@gmail.com = saim)
        'bio': 'Empty bio...',
      });
      //pop loading circle
      if (context.mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessage(e.code, context);
    }
  }

  void displayMessage(String message, context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red[600],
      dismissDirection: DismissDirection.horizontal,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      content: Text(message.toString()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Icon(
                      Icons.lock,
                      size: 100,
                      color: themecolor,
                    ),
                    25.h.verticalSpace,
                    // welcome Text
                    Text(
                      "Let's Create an Account",
                      style: TextStyle(color: Colors.grey[700]),
                    ),

                    SizedBox(
                      height: 25.h,
                    ),
                    // Email Field

                    MyTextFormField(
                      controller: email_controller,
                      hintText: 'Email',
                      obscuretext: false,
                    ),
                    16.h.verticalSpace,
                    // Password Field
                    MyTextFormField(
                      controller: password_controller,
                      hintText: 'Password',
                      obscuretext: false,
                    ),
                    16.h.verticalSpace,
                    MyTextFormField(
                      controller: confirm_password_controller,
                      hintText: 'Confirm Password',
                      obscuretext: false,
                    ),

                    16.h.verticalSpace,

                    // button
                    MyButton(
                      onTap: () => signUp(context),
                      title: 'Sign up',
                    ),
                    25.h.verticalSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account ? ',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            'Login now ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  ]),
            ),
          ),
        ));
  }
}
