import 'dart:async';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../DataBase/Mongodb.dart';

class ConnectivityController extends GetxController {
  var isConnected = true.obs;
  var isDBConnected = false.obs;
  late StreamSubscription<ConnectivityResult> _subscription;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _subscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkInitialConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      await checkInternetConnection();
      print("Network connected");
    } else {
      isConnected.value = false;
      print("Network not connected");
    }
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    await checkInternetConnection();
  }

  Future<void> checkInternetConnection() async {
    bool hasConnection = await InternetConnectionChecker().hasConnection;
    isConnected.value = hasConnection;

    if (hasConnection && !isDBConnected.value) {
      try {
        await MongoDatabase.connect();
        isDBConnected.value = true;
        print("Connected to the database");
      } catch (e) {
        print('Failed to connect to the database: $e');
      }
    } else if (!hasConnection) {
      isDBConnected.value = false;
      print('No internet connection');
    }
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
