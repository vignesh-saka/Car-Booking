import 'package:bookmycar/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import your SearchScreen here
// import 'package:bookmycar/pages/search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book My Car',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(), // 👈 start from Splash always
    );
  }
}
// import 'dart:async';

// import 'package:bookmycar/pages/splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';

// import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final Connectivity _connectivity = Connectivity();

//   // ✅ FIXED TYPE
//   late StreamSubscription<List<ConnectivityResult>> _subscription;

//   bool _noInternetDialogShown = false;

//   @override
//   void initState() {
//     super.initState();
//     _listenToInternet();
//   }

//   void _listenToInternet() async {
//     // 🔹 Initial check (VERY IMPORTANT)
//     final results = await _connectivity.checkConnectivity();
//     _handleConnectivityChange(results);

//     // 🔹 Listen for changes
//     _subscription = _connectivity.onConnectivityChanged.listen(
//       _handleConnectivityChange,
//     );
//   }

//   void _handleConnectivityChange(List<ConnectivityResult> results) {
//     final bool isConnected =
//         results.contains(ConnectivityResult.mobile) ||
//         results.contains(ConnectivityResult.wifi);

//     if (!isConnected && !_noInternetDialogShown) {
//       _noInternetDialogShown = true;

//       // ✅ Wait until UI is ready
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _showNoInternetDialog();
//       });
//     }

//     if (isConnected && _noInternetDialogShown) {
//       _noInternetDialogShown = false;

//       if (Navigator.canPop(context)) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }
//     }
//   }

//   void _showNoInternetDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         title: Row(
//           children: const [
//             Icon(Icons.wifi_off, color: Colors.red),
//             SizedBox(width: 8),
//             Text("No Internet"),
//           ],
//         ),
//         content: const Text(
//           "Please turn on your internet connection to continue using Book My Car.",
//         ),
//         actions: [ElevatedButton(onPressed: () {}, child: const Text("OK"))],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Book My Car',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const SplashScreen(), // 👈 unchanged
//     );
//   }
// }
