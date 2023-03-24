import 'dart:io';

import 'package:bs_flutter/const/constant.dart';
import 'package:bs_flutter/widget/logout_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class ClaimScreen extends StatefulWidget {
  const ClaimScreen({Key? key}) : super(key: key);

  @override
  State<ClaimScreen> createState() => _ClaimScreenState();
}

class _ClaimScreenState extends State<ClaimScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();

  String? type;
  String? title;
  String? content;

  String? imagePath;
  String? imageName;
  XFile? imageXFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("사용자 문의"),
        actions: [
          logoutButton(context),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                TextFormField(
                  onSaved: (value) {
                    title = value;
                  },
                  decoration: InputDecoration(
                    hintText: "제목",
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '제목을 입력해 주세요';
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                TextFormField(
                  maxLines: 20,
                  minLines: 10,
                  onSaved: (value) {
                    content = value;
                  },
                  decoration: InputDecoration(
                    hintText: "내용",
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '내용을 입력해 주세요';
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                previewPhoto(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final image = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );
                        setState(
                          () {
                            imagePath = image!.path;
                            imageName = image.name;
                            imageXFile = image;
                          },
                        );
                      },
                      child: Text("사진 불러오기"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final image = await ImagePicker().pickImage(
                          source: ImageSource.camera,
                        );
                        setState(
                          () {
                            imagePath = image!.path;
                            imageName = image.name;
                            imageXFile = image;
                          },
                        );
                      },
                      child: Text("촬영하기"),
                    ),
                    ElevatedButton(
                      child: Text("게시"),
                      onPressed: () async {
                        if (formKey.currentState == null) {
                          return;
                        }
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          Map claimInfo = {
                            'title': title,
                            'content': content,
                          };
                          await Dio().post(
                            '$API_DOMAIN/flutter/return',
                            data: FormData.fromMap(
                              {
                                "image": MultipartFile.fromFileSync(imagePath!),
                                ...claimInfo,
                              },
                            ),
                          );
                        }
                        await postImage(imageXFile);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget previewPhoto() {
    if (imagePath == null) {
      return Container();
    } else {
      return Column(
        children: [
          Image.file(
            File(imagePath!),
            width: 200,
            height: 200,
          ),
        ],
      );
    }
  }
  postImage(dynamic input) async {
    print("사진을 서버에 업로드 합니다.");
    try {
      var response = await Dio().post(
        '$API_DOMAIN/articles/uploadfile/',
        data: FormData.fromMap(
          {
            "image": MultipartFile.fromFileSync(input.path),
          },
        ),
      );
      print(response.data);
      return response.data;
    } catch (e) {
      print(e);
    }
  }
}
