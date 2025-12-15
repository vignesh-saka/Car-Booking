import 'package:flutter/material.dart';

void showNoInternetDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.red),
          SizedBox(width: 8),
          Text("No Internet"),
        ],
      ),
      content: Text(
        "Please turn on your internet connection to continue using the app.",
      ),
      actions: [
        ElevatedButton(
          onPressed: () {},
          child: Text("OK"),
        ),
      ],
    ),
  );
}
