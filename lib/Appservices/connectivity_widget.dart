import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'connectivity_controller.dart';

class ConnectivityWidget extends StatefulWidget {

  const ConnectivityWidget({Key? key}) : super(key: key);
  _ConnectivityWidget createState() => _ConnectivityWidget();
}

class _ConnectivityWidget extends State<ConnectivityWidget> {
  _ConnectivityWidget({Key? key});

  

  @override
  Widget build(BuildContext context) {
    final connectivityController = Get.find<ConnectivityController>();
    return Obx(() {
      return Stack(
        children: [
          if (!connectivityController.isConnected.value)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.grey,
                width: double.infinity,
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(width: 8.0),
                    Text(
                      'No internet connection',
                      style: TextStyle(color: Colors.white, decoration: TextDecoration.none, fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}
