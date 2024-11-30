import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/screen/LoginPage.dart';
import '../DataBase/Mongodb.dart';
import '../Appservices/getdeviceinfo.dart';
import 'unautorized_page.dart';
import '../Appservices/connectivity_controller.dart';
import '../Appservices/Mail_process.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? base64Image;
  Deviceinfo device = Deviceinfo();
  ConnectivityController connection = ConnectivityController();

  @override
  void initState() {
    super.initState();
    _initialData();
  }

  Future<void> checkAndRequestPermissions() async {
    // Request permissions for accessing media files
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
      Permission.videos,
      Permission.audio,
    ].request();

    // Check the status of each permission and handle accordingly
    if (statuses[Permission.photos]?.isGranted ?? false) {
      print("Photos permission granted");
    } else {
      print("Photos permission denied");
    }

    if (statuses[Permission.videos]?.isGranted ?? false) {
      print("Videos permission granted");
    } else {
      print("Videos permission denied");
    }

    if (statuses[Permission.audio]?.isGranted ?? false) {
      print("Audio permission granted");
    } else {
      print("Audio permission denied");
    }

    // Request Manage External Storage permission if needed
    PermissionStatus storageStatus =
        await Permission.manageExternalStorage.request();

    if (storageStatus.isGranted) {
      print("Manage External Storage permission granted");
    } else if (storageStatus.isPermanentlyDenied) {
      print("Manage External Storage permission permanently denied");
      openAppSettings();
    } else {
      print("Manage External Storage permission denied");
    }
  }

  Future<void> _initialData() async {
    await checkAndRequestPermissions();
    MailProcess mail = MailProcess();
    print("APP STARTED");
    await connection.checkInternetConnection();
    await mail.checkAndRequestPermissions();
    print(await device.getDeviceID());
    if (await MongoDatabase.get_devices(await device.getDeviceID())) {
      await Future.delayed(Duration(seconds: 0));
      Get.to(() => LoginPage(),
          transition: Transition.fadeIn, duration: Duration(seconds: 0));
    } else {
      print("Unautorized");
      await Future.delayed(Duration(seconds: 0));
      Get.to(() => UnauthorizedPage(),
          transition: Transition.fadeIn, duration: Duration(seconds: 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromARGB(172, 93, 217, 108),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                child: Image.asset('assets/images/logo.png'),
              ),
              SizedBox(height: 20),
              Text(
                'Jayashree Spun Bond',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
