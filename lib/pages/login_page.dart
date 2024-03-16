import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:word_wall/auth/login_or_register.dart';
import 'package:word_wall/components/myTextFormFields.dart';
import 'package:word_wall/components/mybutton.dart';
import 'package:word_wall/constants.dart';
import 'package:word_wall/controllers/login_or_register_controller.dart';
import 'package:word_wall/pages/Forgot_pass_page.dart';
import 'package:word_wall/pages/home_page.dart';
import 'package:word_wall/utils/utils.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  LoginPage({
    super.key,
    required this.onTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email_controller = TextEditingController();

  final password_controller = TextEditingController();

  final currentUser = FirebaseAuth.instance.currentUser;

  void signIn(context) async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email_controller.text, password: password_controller.text);
      Navigator.pop(context);
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
        backgroundColor: Theme.of(context).colorScheme.background,
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
                      color: Color(0xff00B4D8),
                    ),
                    30.h.verticalSpace,
                    // welcome Text
                    Text(
                      "Welcome back !",
                      style: TextStyle(
                          fontFamily: GoogleFonts.righteous().fontFamily,
                          fontSize: 35.sp),
                    ),

                    SizedBox(
                      height: 25.h,
                    ),
                    // Email Field

                    MyTextFormField(
                      controller: email_controller,
                      hintText: 'Email',
                      obscuretext: false,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    16.h.verticalSpace,
                    // Password Field
                    MyTextFormField(
                      controller: password_controller,
                      hintText: 'Password',
                      obscuretext: false,
                    ),

                    16.h.verticalSpace,

                    // button
                    MyButton(
                      onTap: () {
                        signIn(context);
                      },
                      title: 'Sign in',
                    ),

                    25.h.verticalSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotPasswordPage())),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            'Sign up ! ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
            ),
          ),
        ));
  }
}
