import 'package:bs_flutter/screen/chatbot_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

Widget chatbotButton(context) {
  return FloatingActionButton(
    onPressed: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => ChatbotScreen(),
        ),
      );
    },
    child: Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(math.pi),
      child: Icon(Icons.chat),
    ),
  );
}
