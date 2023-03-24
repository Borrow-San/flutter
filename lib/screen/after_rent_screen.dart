import 'package:bs_flutter/screen/return_screen.dart';
import 'package:bs_flutter/widget/chatbot_button.dart';
import 'package:bs_flutter/widget/check_location_permission.dart';
import 'package:bs_flutter/widget/logout_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class AfterRentScreen extends StatefulWidget {
  const AfterRentScreen({Key? key}) : super(key: key);

  @override
  State<AfterRentScreen> createState() => _AfterRentScreenState();
}

class _AfterRentScreenState extends State<AfterRentScreen> {
  final standLatitude = 37.5706;
  final standLongitude = 126.9853;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("After Rent Screen"),
        actions: [
          logoutButton(context),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<String>(
            future: checkLocationPermission(),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.data == '위치 권한이 허가 되었습니다.') {
                return FutureBuilder(
                  future: OverlayImage.fromAssetImage(
                    assetName: 'assets/images/umb_icon.png',
                  ),
                  builder: (context, snapshot) {
                    return NaverMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(standLatitude, standLongitude),
                        zoom: 15,
                      ),
                      markers: [
                        Marker(
                          markerId: '1',
                          position: LatLng(standLatitude, standLongitude),
                          icon: snapshot.data,
                          width: 32,
                          height: 32,
                          onMarkerTab: (marker, iconSize) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("우산 반납 화면으로\n이동하시겠습니까?"),
                                  content: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => ReturnScreen(),
                                            ),
                                          );
                                        },
                                        child: Text("예"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("아니오"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              }
              return Center(
                child: Text(
                  snapshot.data.toString(),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    chatbotButton(context),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
