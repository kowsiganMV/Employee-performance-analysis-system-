import 'package:app/screen/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Appservices/connectivity_controller.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ConnectivityController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),//MongoDbInsert(),
    );
  }
}
