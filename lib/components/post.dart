import 'package:flutter/material.dart';

class Post extends StatelessWidget {
  const Post({
    super.key,
    required this.message,
    required this.user,
  });

  final String message;
  final String user;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Column(children: [
        Text(user),
        Text(message),
      ])
    ]);
  }
}
