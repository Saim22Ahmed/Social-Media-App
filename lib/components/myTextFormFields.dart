import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:word_wall/constants.dart';

class MyTextFormField extends StatelessWidget {
  MyTextFormField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.expands,
    this.maxlines,
    this.onChanged,
    required this.obscuretext,
    this.keyboardType,
    this.onTap,
    this.readOnly = false,
    this.validator,
    this.autovalidateMode,
  });
  final String hintText;
  final Icon? prefixIcon;
  final Icon? suffixIcon;
  final TextEditingController? controller;
  final bool? expands;
  final int? maxlines;
  final bool obscuretext;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final Function()? onTap;
  final bool readOnly;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: TextFormField(
        autovalidateMode: autovalidateMode,
        validator: validator,
        obscureText: obscuretext,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        expands: expands ?? false,
        controller: controller,
        onTapOutside: (event) {
          FocusScope.of(context).unfocus();
        },
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.center,

        textInputAction: TextInputAction.next,
        // autofocus: true,
        maxLines: maxlines,
        cursorColor: Colors.blue,

        style: TextStyle(
          // height: 1.h,
          fontSize: 16.sp,
        ),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8.w),
          filled: true,
          fillColor: const Color(0x379E9E9E),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(4.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: themecolor,
              width: 1.w,
            ),
            borderRadius: BorderRadius.circular(4.r),
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey[500],
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,

          // prefixIcon: Icon(EvaIcons.email, color: myColors.theme_turquoise.blue)
        ),
      ),
    );
  }
}
