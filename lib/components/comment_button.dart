import 'package:flutter/material.dart';

class CommentButton extends StatelessWidget {
  CommentButton({super.key, required this.onTap});

  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(Icons.comment, color: Colors.grey),
    );
  }
}
