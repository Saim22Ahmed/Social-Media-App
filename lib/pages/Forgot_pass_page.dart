import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:word_wall/components/myTextFormFields.dart';
import 'package:word_wall/utils/utils.dart';

class ForgotPasswordPage extends StatefulWidget {
  ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final email_controller = TextEditingController();

  // reset password method
  ResetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email_controller.text.trim());
      Utils.OneLineCustomSnackBar(
        context,
        text: 'Reset link has been sent!',
        duration: 2500.ms,
        color: Colors.green[600],
        icon: Icons.error,
      );
    } on FirebaseAuthException catch (e) {
      Utils.OneLineCustomSnackBar(
        context,
        text: e.message.toString(),
        duration: 2500.ms,
        color: Colors.red,
        icon: Icons.error,
      );
      ;
    }
  }

  @override
  void dispose() {
    email_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Forgot Password ?',
              style: TextStyle(
                  fontFamily: GoogleFonts.righteous().fontFamily,
                  fontSize: 35.sp),
            ),

            20.h.verticalSpace,

            // description text

            Text(
              'No worries ! Please enter your email address. You will receive a link to create a new password via email.',
              style: TextStyle(
                  fontFamily: GoogleFonts.josefinSans().fontFamily,
                  fontSize: 16.sp),
            ),

            50.h.verticalSpace,

            //Email textField
            MyTextFormField(
              hintText: 'Email',
              obscuretext: false,
              controller: email_controller,
            ),

            30.h.verticalSpace,

            // Reset password button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff00B4D8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: ResetPassword,
              child: Text(
                'Reset Password',
                style: TextStyle(
                    fontFamily: GoogleFonts.righteous().fontFamily,
                    fontSize: 20.sp,
                    color: Theme.of(context).colorScheme.onTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
