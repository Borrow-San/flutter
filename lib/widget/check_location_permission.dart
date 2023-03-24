import 'package:geolocator/geolocator.dart';

Future<String> checkLocationPermission() async {
  final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
  if (!isLocationEnabled) {
    return "위치 서비스를 활성화해주세요.";
  }
  LocationPermission checkedPermission = await Geolocator.checkPermission();
  if (checkedPermission == LocationPermission.denied) {
    checkedPermission = await Geolocator.requestPermission();
    if (checkedPermission == LocationPermission.denied) {
      return "위치 권한을 허가해주세요.";
    }
  }
  if (checkedPermission == LocationPermission.deniedForever) {
    return "앱의 위치 권한을 설정에서 허가해주세요.";
  }
  return "위치 권한이 허가 되었습니다.";
}