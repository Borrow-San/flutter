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

class RentScreen extends StatefulWidget {
  const RentScreen({Key? key}) : super(key: key);

  @override
  State<RentScreen> createState() => _RentScreenState();
}

class _RentScreenState extends State<RentScreen> {
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
        title: Text("Rent Screen"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BeforeRentScreen(),
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
                  setState(
                    () {
                      removeQrScannerOverlayShape = true;
                    },
                  );
                  controller.pauseCamera().then(
                    (_) async {
                      final capturedImg = await screenshotController.capture();
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
                                    child: Text("대여"),
                                    onPressed: () async {
                                      await Dio()
                                          .post(
                                        '$API_DOMAIN/flutter/rent',
                                        data: jsonEncode(
                                          {
                                            "token": snapshot.data,
                                            "qr_code": qrCode,
                                          },
                                        ),
                                      )
                                          .then(
                                        (value) {
                                          if (value.data['msg'] == null) {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title:
                                                      Text("서버와 통신에 실패하였습니다"),
                                                  actions: [
                                                    ElevatedButton(
                                                      child: Text("확인"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else if (value.data['msg'] ==
                                              "대여 성공") {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text("대여 성공했습니다"),
                                                  actions: [
                                                    ElevatedButton(
                                                      child: Text("확인"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                AfterRentScreen(),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else if (value.data['msg'] ==
                                              "대여 실패") {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text("대여 실패했습니다"),
                                                  actions: <Widget>[
                                                    ElevatedButton(
                                                      child: Text("확인"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                RentScreen(),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ], // add this
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
