import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:word_wall/auth/Auth.dart';
import 'package:word_wall/auth/login_or_register.dart';
import 'package:word_wall/firebase_options.dart';
import 'package:word_wall/pages/login_page.dart';
import 'package:word_wall/pages/register_page.dart';
import 'package:word_wall/pages/splash_page.dart';
import 'package:word_wall/theme/dark_theme.dart';
import 'package:word_wall/theme/light_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 892),
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: lightTheme,
          darkTheme: darkTheme,
          home: SplashScreen(),
        );
      },
    );
  }
}
