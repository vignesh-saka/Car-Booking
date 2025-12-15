import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetChecker {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _subscription;

  void startListening(Function(bool isConnected) onChange) {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      final bool isConnected =
          result != ConnectivityResult.none;
      onChange(isConnected);
    });
  }

  void dispose() {
    _subscription.cancel();
  }
}
