import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:word_wall/auth/Auth.dart';
import 'package:word_wall/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // Future.delayed(Duration(seconds: 10), () {
    //   Navigator.push(
    //       context, MaterialPageRoute(builder: (context) => AuthPage()));
    // });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
              Color(0xff00B4D8),
              Color(0xff0A6678),
            ])),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'thoughtfull',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.nunito().fontFamily,
                  ),
                ),
                SizedBox(width: 15.w),
                Icon(
                  Icons.motion_photos_on,
                  color: Colors.white,
                  size: 54.sp,
                )
              ],
            )
                .animate(
                  onPlay: (controller) => controller.repeat(),
                )
                .shimmer(
                  angle: 45,
                  duration: Duration(seconds: 2),
                ),
          ],
        ),
      ),
    ));
  }
}
