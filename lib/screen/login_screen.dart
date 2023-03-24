import 'dart:convert';
import 'package:bs_flutter/const/constant.dart';
import 'package:bs_flutter/screen/chatbot_screen.dart';
import 'package:bs_flutter/screen/before_rent_screen.dart';
import 'package:bs_flutter/screen/sign_up_screen.dart';
import 'package:bs_flutter/widget/chatbot_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();

  String? user_app_id;
  String? password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Screen"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      onSaved: (value) {
                        user_app_id = value;
                      },
                      decoration: InputDecoration(
                        hintText: "ID",
                        filled: true,
                        fillColor: Colors.grey.shade200,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ID를 입력해 주세요';
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    TextFormField(
                      obscureText: true,
                      onSaved: (value) {
                        password = value;
                      },
                      decoration: InputDecoration(
                        hintText: "Password",
                        filled: true,
                        fillColor: Colors.grey.shade200,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password를 입력해 주세요';
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    ElevatedButton(
                      child: Text("로그인"),
                      onPressed: () async {
                        if (formKey.currentState == null) {
                          return;
                        }
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          Map loginInfo = {'user_app_id': user_app_id, 'password': password};
                          final response = await Dio().post(
                            '$API_DOMAIN/users/login',
                            data: jsonEncode(loginInfo),
                          );
                          if (response.data["msg"] == null) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("서버가 반응하지 않습니다"),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("확인"),
                                    )
                                  ],
                                );
                              },
                            );
                          } else if (response.data["msg"] ==
                              "FAILURE: 비밀번호가 일치하지 않습니다") {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("비밀번호가 일치하지 않습니다"),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("확인"),
                                    )
                                  ],
                                );
                              },
                            );
                          } else if (response.data['msg'] ==
                              "FAILURE: 아이디가 존재하지 않습니다") {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("아이디가 존재하지 않습니다"),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("확인"),
                                    )
                                  ],
                                );
                              },
                            );
                          } else {
                            setState(
                              () {
                                FlutterSecureStorage()
                                    .write(key: "token", value: response.data['msg']);
                              },
                            );
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("로그인 되었습니다."),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => BeforeRentScreen(),
                                          ),
                                        );
                                      },
                                      child: Text("확인"),
                                    )
                                  ],
                                );
                              },
                            );
                          }
                        }
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(),
                          ),
                        );
                      },
                      child: Text("회원가입"),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                chatbotButton(context),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
