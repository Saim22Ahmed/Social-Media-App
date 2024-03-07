import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeleteButton extends StatelessWidget {
  const DeleteButton({super.key, required this.onTap});

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(Icons.delete_outline_rounded,
          size: 26.sp, color: Theme.of(context).colorScheme.onTertiary),
    );
  }
}
