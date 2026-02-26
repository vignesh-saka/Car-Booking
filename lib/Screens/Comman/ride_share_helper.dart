import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class RideShareHelper {
  static Future<void> shareRide({
    required BuildContext context,
    required String date,
    required String time,
    required String from,
    required String to,
    required int availableSeats,
    required String driverName,
  }) async {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    
    final String fromCity = from.split(' ').first;
    final String toCity = to.split(' ').first;

    final String rideDetails = '''
🚘 *Ride Details* 🚘

📅 *Date:* $date
⏰ *Time:* $time 

📍  From: *$fromCity*
📍  To: *$toCity*

💺 *Available Seats:* $availableSeats
👤 *Driver:* $driverName

---
Shared via *Book My Car App*
''';

    await Share.share(
      rideDetails,
      subject: 'Ride Details',
      sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
    );
  }
}
