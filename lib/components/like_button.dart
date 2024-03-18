import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CustomLikeButton extends StatelessWidget {
  const CustomLikeButton(
      {super.key, required this.isLiked, required this.onTap});

  final bool isLiked;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Icon(
          isLiked ? Icons.favorite : Icons.favorite_outline,
          color: isLiked ? Colors.red : Colors.grey,
        ));
    // animation should begin when user like the post
  }
}
