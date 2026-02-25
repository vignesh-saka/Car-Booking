import 'package:bookmycar/Screens/My_Booking_Screens/Model/models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;

  const BookingCard({
    super.key,
    required this.booking,
  });

  // --------- ADDRESS HELPERS ---------
  Map<String, String> _splitAddress(String s) {
    final trimmed = s.trim();
    if (trimmed.isEmpty) return {'city': '', 'rest': ''};
    final parts = trimmed.split(',');
    final city = parts[0].trim();
    final rest =
        parts.length > 1 ? parts.sublist(1).join(',').trim() : '';
    return {'city': city, 'rest': rest};
  }

  Widget _buildAddressColumn(String address) {
    final parts = _splitAddress(address);
    final city = parts['city']!;
    final rest = parts['rest']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          city,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lexend(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (rest.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            rest,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lexend(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  // --------- POPUP FOR PASSENGER DETAILS ---------
  void _showPassengerPopup(BuildContext context) {
    final passengers = booking.passengers;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          title: Text(
            passengers.length > 1
                ? 'Group of ${passengers.length}'
                : 'Passenger Details',
            style: GoogleFonts.lexend(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: passengers.isEmpty
                ? Text(
                    'No passenger details available',
                    style: GoogleFonts.lexend(),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: passengers.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final p =
                          (passengers[index] as Map?) ?? <String, dynamic>{};
                      final name =
                          (p['name'] ?? 'Passenger').toString();
                      final age =
                          (p['age'] ?? 'N/A').toString();
                      final phone =
                          (p['phone'] ?? 'N/A').toString();

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Passenger ${index + 1}',
                              style: GoogleFonts.lexend(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _detailRow('Name:', name),
                            const SizedBox(height: 2),
                            _detailRow('Age:', age),
                            const SizedBox(height: 2),
                            _detailRow('Phone:', phone),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          actionsPadding:
              const EdgeInsets.only(right: 12, bottom: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.lexend(
                  color: const Color(0xFFFF3B30),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // helper for "Name: value" / "Age: value" / "Phone: value"
  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===================== TOP ROW =====================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.startTime,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildAddressColumn(booking.from),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Rs: ${booking.price}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFF4444),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ===================== SECOND ROW =====================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.endTime,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.location_on,
                size: 16,
                color: Colors.black54,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildAddressColumn(booking.to),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ===================== DRIVER INFO + DESCRIPTION =====================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, color: Colors.grey[600]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (booking.description.trim().isNotEmpty) ...[
                      Text(
                        booking.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lexend(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 3),
                    ],
                    Text(
                      booking.driverName,
                      style: GoogleFonts.lexend(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      booking.driverPhone,
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ===================== GROUP BADGE (TAP FOR POPUP) =====================
          if (booking.passengerCount > 0) ...[
            GestureDetector(
              onTap: () => _showPassengerPopup(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade300),
                ),
                child: Text(
                  'Group of ${booking.passengerCount}',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ===================== STATUS BADGE =====================
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _getStatusColor(),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                booking.status.toUpperCase(),
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (booking.status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'requested':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
