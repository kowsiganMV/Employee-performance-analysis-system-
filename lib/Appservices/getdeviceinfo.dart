import 'package:device_info_plus/device_info_plus.dart';

class Deviceinfo {
  Future<String> getDeviceID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String deviceID = androidInfo.id.toString();
    return deviceID;
  }
}
