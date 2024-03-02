import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class LoginOrRegisterController extends GetxController {
  RxBool isLogin = true.obs;
  RxBool isLoading = false.obs;

  togglePages() {
    isLogin.value = !isLogin.value;
  }
}
