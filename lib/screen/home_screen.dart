import 'package:bs_flutter/screen/after_rent_screen.dart';
import 'package:bs_flutter/screen/chatbot_screen.dart';
import 'package:bs_flutter/screen/login_screen.dart';
import 'package:bs_flutter/screen/rent_screen.dart';
import 'package:bs_flutter/screen/return_screen.dart';
import 'package:bs_flutter/screen/sign_up_screen.dart';
import 'package:bs_flutter/screen/start_screen.dart';
import 'package:flutter/material.dart';

import 'before_rent_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: _navigationList
                .map(
                  (buttonName) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 16.0),
                        _navigationButton(context, buttonName),
                      ],
                    );
                  }
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  final List<String> _navigationList = [
    "Start Screen",
    "Sign Up Screen",
    "Login Screen",
    "Before Rent Screen",
    "Rent Screen",
    "After Rent Screen",
    "Return Screen",
    "Chatbot Screen",
  ];

  final Map<String, Widget> _navigationMap = {
    "Chatbot Screen": ChatbotScreen(),
    "Login Screen": LoginScreen(),
    "Sign Up Screen": SignUpScreen(),
    "Before Rent Screen": BeforeRentScreen(),
    "After Rent Screen": AfterRentScreen(),
    "Rent Screen": RentScreen(),
    "Return Screen": ReturnScreen(),
    "Start Screen": StartScreen(),
  };

  Widget _navigationButton(BuildContext context, String buttonName) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => _navigationMap[buttonName]!,
          ),
        );
      },
      child: Text(buttonName),
    );
  }
}
