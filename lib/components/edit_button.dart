import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditButton extends StatelessWidget {
  const EditButton({super.key, required this.onTap});

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(Icons.edit,
          size: 26.sp, color: Theme.of(context).colorScheme.onTertiary),
    );
  }
}
