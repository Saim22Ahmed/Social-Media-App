import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:word_wall/pages/login_page.dart';
import 'package:word_wall/pages/register_page.dart';
import 'package:word_wall/controllers/login_or_register_controller.dart';

class LoginOrRegisterPage extends StatefulWidget {
  LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  final loginOrRegisterController = Get.put(LoginOrRegisterController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => loginOrRegisterController.isLogin.value
        ? LoginPage(
            onTap: () => loginOrRegisterController.togglePages(),
          )
        : RegisterPage(
            onTap: () => loginOrRegisterController.togglePages(),
          ));
  }
}
