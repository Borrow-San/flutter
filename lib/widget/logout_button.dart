import 'package:bs_flutter/const/constant.dart';
import 'package:bs_flutter/screen/start_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Widget logoutButton(context) {
  return FutureBuilder(
    future: FlutterSecureStorage().read(key: "token"),
    builder: (context, snapshot) {
      return IconButton(
        icon: Icon(Icons.logout),
        onPressed: () async {
          if (snapshot.data != null) {
            await Dio()
                .post(
              '$API_DOMAIN/users/logout',
              options: Options(
                headers: {
                  "token": snapshot.data,
                }, // Disable gzip
              ),
            )
                .then(
              (value) {
                print("### response : ${value.data}");
                if (value.data["msg"] == "로그아웃 성공") {
                  FlutterSecureStorage().delete(key: "token");
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("로그아웃 성공"),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => StartScreen(),
                                ),
                              );
                            },
                            child: Text("확인"),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("로그아웃 실패"),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("확인"),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            );
          }
        },
      );
    },
  );
}
