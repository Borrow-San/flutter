import 'dart:convert';
import 'package:bs_flutter/const/constant.dart';
import 'package:bs_flutter/screen/after_rent_screen.dart';
import 'package:bs_flutter/screen/before_rent_screen.dart';
import 'package:bs_flutter/widget/logout_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:screenshot/screenshot.dart';

class ReturnScreen extends StatefulWidget {
  const ReturnScreen({Key? key}) : super(key: key);

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  final screenshotController = ScreenshotController();
  String? qrCode;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool removeQrScannerOverlayShape = false;

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Return Screen"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AfterRentScreen(),
              ),
            );
          },
        ),
        actions: [
          logoutButton(context),
        ],
      ),
      body: Screenshot(
        controller: screenshotController,
        child: QRView(
          key: qrKey,
          overlay: renderQrScannerOverlayShape(deviceWidth),
          onQRViewCreated: (controller) {
            controller.scannedDataStream.listen(
              (scanData) {
                if (scanData.code == null) {
                  return;
                } else {
                  qrCode = scanData.code;
                  setState(() {
                    removeQrScannerOverlayShape = true;
                  });
                  controller.pauseCamera().then(
                    (_) async {
                      final capturedImg = await screenshotController.capture(
                        pixelRatio: 0.50,
                      );
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Image.memory(
                              capturedImg!,
                              width: deviceWidth * 0.75,
                              height: deviceWidth * 0.75,
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(
                                    () {
                                      removeQrScannerOverlayShape = false;
                                    },
                                  );
                                  Navigator.pop(context);
                                  controller.resumeCamera();
                                },
                                child: Text("다시 스캔"),
                              ),
                              FutureBuilder(
                                future:
                                    FlutterSecureStorage().read(key: "token"),
                                builder: (context, snapshot) {
                                  return ElevatedButton(
                                    child: Text("반납"),
                                    onPressed: () async {
                                      await Dio()
                                          .post(
                                        '$API_DOMAIN/flutter/return',
                                        data: jsonEncode(
                                          {
                                            "token": snapshot.data,
                                            "qr_code": qrCode,
                                            "image": capturedImg,
                                          },
                                        ),
                                      )
                                          .then(
                                        (value) {
                                          print("##### ${value.data["msg"]}");
                                          if (value.data["msg"] == null) {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    "서버 통신에 실패했습니다",
                                                  ),
                                                  actions: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        controller
                                                            .resumeCamera();
                                                      },
                                                      child: Text("확인"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else if (value.data["msg"] ==
                                              "반납이 완료되었습니다") {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    "반납이 완료되었습니다",
                                                  ),
                                                  actions: [
                                                    ElevatedButton(
                                                      child: Text("확인"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                BeforeRentScreen(),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else if (value.data["msg"] ==
                                              "우산 파손으로 반납이 불가합니다") {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    "우산 파손으로 반납이 불가합니다",
                                                  ),
                                                  actions: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        controller
                                                            .resumeCamera();
                                                      },
                                                      child: Text("확인"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else if (value.data["msg"] ==
                                              "우산 인식에 실패했습니다") {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    "우산 인식에 실패했습니다",
                                                  ),
                                                  actions: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        controller
                                                            .resumeCamera();
                                                      },
                                                      child: Text("확인"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else if (value.data["msg"] ==
                                              "회원정보 혹은 우산 정보가 일치하지 않습니다") {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    "회원정보 혹은 우산 정보가 일치하지 않습니다",
                                                  ),
                                                  actions: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        controller
                                                            .resumeCamera();
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
                                    },
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  QrScannerOverlayShape renderQrScannerOverlayShape(deviceWidth) {
    if (removeQrScannerOverlayShape == false) {
      return QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 5,
        borderLength: 15,
        borderWidth: 5,
        cutOutSize: deviceWidth * 0.2,
      );
    } else {
      return QrScannerOverlayShape(
        overlayColor: Colors.black.withOpacity(0.0),
      );
    }
  }
}
