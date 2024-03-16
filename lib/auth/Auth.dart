import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:word_wall/auth/login_or_register.dart';
import 'package:word_wall/pages/home_page.dart';
import 'package:word_wall/pages/login_page.dart';
import 'package:word_wall/pages/verifyEmail_page.dart';

class AuthPage extends StatelessWidget {
  AuthPage({super.key});

  // current user
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return VerifyEmailPage();
          } else {
            return LoginOrRegisterPage();
          }
        });
  }
}
