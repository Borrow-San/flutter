import 'dart:convert';

import 'package:bs_flutter/const/constant.dart';
import 'package:bs_flutter/screen/login_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();
  String? user_app_id;
  String? password;
  String? passwordCheck;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up Screen"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                  labelText: "ID",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "아이디을 입력해주세요";
                  } else if (value.length < 4) {
                    return "아이디는 4자 이상이어야 합니다";
                  } else if (value.length > 20) {
                    return "아이디는 20자 이하이어야 합니다";
                  }
                  return null;
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              TextFormField(
                obscureText: true,
                onSaved: (value) {
                  password = value;
                },
                decoration: InputDecoration(
                  labelText: "Password",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "비밀번호를 입력해주세요";
                  } else if (value.length < 4) {
                    return "비밀번호는 4자 이상이어야 합니다";
                  } else if (value.length > 20) {
                    return "비밀번호는 20자 이하이어야 합니다";
                  }
                  return null;
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              TextFormField(
                onSaved: (value) {
                  passwordCheck = value;
                },
                decoration: InputDecoration(
                  labelText: "Password Check",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "비밀번호를 한번 더 입력해 주세요";
                  } else if (value.length < 4) {
                    return "비밀번호는 4자 이상이어야 합니다";
                  } else if (value != password) {
                    return "비밀번호가 일치하지 않습니다";
                  } else if (value.length > 20) {
                    return "비밀번호는 20자 이하이어야 합니다";
                  }
                  return null;
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              ElevatedButton(
                child: Text("회원가입"),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                  }
                  if (password != passwordCheck) {
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
                  } else {
                    final response = await Dio().post(
                      '$API_DOMAIN/users/register',
                      data: jsonEncode(
                        {
                          'user_app_id': user_app_id,
                          'password': password,
                        },
                      ),
                    );
                    if (response.data['msg'] == null) {
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
                    } else if (response.data['msg'] ==
                        "SUCCESS: 회원가입이 완료되었습니다") {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("가입 완료되었습니다"),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => LoginScreen(),
                                    ),
                                  );
                                },
                                child: Text("확인"),
                              )
                            ],
                          );
                        },
                      );
                    } else if (response.data['msg'] ==
                        "FAILURE: 회원가입이 실패하였습니다") {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("가입 실패하였습니다"),
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
                        "FAILURE: 아이디가 이미 존재합니다") {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("아이디가 이미 존재합니다"),
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
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
