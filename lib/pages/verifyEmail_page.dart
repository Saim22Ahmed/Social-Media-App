import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:word_wall/pages/home_page.dart';
import 'package:word_wall/utils/utils.dart';

class VerifyEmailPage extends StatefulWidget {
  VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  Timer? timer;
  bool canResenEmail = false;

  @override
  void initState() {
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    // TODO: implement initState
    super.initState();

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  Future sendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      Utils.CustomSnackBar(context,
          text: 'Email has been sent !',
          subtitle: ' please check your inbox and verify.',
          color: Colors.green[600]!,
          icon: Icons.check,
          duration: 2500.ms);

      setState(() => canResenEmail = false);
      Future.delayed(
          Duration(seconds: 5), () => setState(() => canResenEmail = true));
    } catch (e) {
      Utils.CustomSnackBar(context, text: e.toString(), duration: 2000.ms);
    }
  }

  checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) timer?.cancel();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isEmailVerified) {
      return HomePage();
    } else {
      return Scaffold(
          body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Verify your email",
              style: TextStyle(
                  fontSize: 35.sp,
                  fontFamily: GoogleFonts.righteous().fontFamily),
            ),
            10.h.verticalSpace,

            // Verify email description

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: Colors.transparent,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withOpacity(0.4),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "A verification email has been sent to your account , please click the link and verify your email.",
                      style: TextStyle(
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            30.h.verticalSpace,

            // Resend email button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff00B4D8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                onPressed: () {
                  canResenEmail ? sendVerificationEmail() : null;
                },
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Resend Email",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                      10.w.horizontalSpace,
                      Container(
                        margin: EdgeInsets.only(bottom: 5.h),
                        child: Icon(
                          Icons.email,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),
                    ]),
              ),
            ),

            10.h.verticalSpace,

            //Cancel Button

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600]!.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    "Cancel",
                    style: TextStyle(fontSize: 16.sp, color: Colors.white),
                  ),
                  10.w.horizontalSpace,
                ]),
              ),
            ),
          ],
        ),
      ));
    }
  }
}
