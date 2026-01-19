import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Termsandconditions extends StatelessWidget {
  const Termsandconditions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF3B30),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Terms & Conditions",
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionText("Last updated: 17/12/2025", isMuted: true),
            const SizedBox(height: 16),

            _sectionText(
              "Welcome to Book My Car.\n\n"
              "By creating an account or using this application, you agree to follow and be bound by the Terms & Conditions described below. "
              "Please read them carefully before using the app.",
            ),

            _sectionTitle("1. About Book My Car"),
            _sectionText(
              "Book My Car is a ride-sharing platform that allows users to:\n\n"
              "• Publish rides as a rider (driver)\n"
              "• Search and book available rides as a passenger\n"
              "• Manage bookings, ride requests, and ride history\n\n"
              "Book My Car acts only as a technology platform to connect riders and passengers. "
              "We do not provide transportation services directly.",
            ),

            _sectionTitle("2. User Eligibility"),
            _sectionText(
              "To use this app:\n\n"
              "• You must be 18 years or older\n"
              "• You must provide accurate and complete information during signup\n"
              "• You are responsible for keeping your login credentials secure\n\n"
              "If false or misleading information is found, we reserve the right to suspend or delete your account.",
            ),

            _sectionTitle("3. Account Registration & Security"),
            _sectionText(
              "• Users can sign up using Email & Password or Google Sign-In\n"
              "• You are responsible for all activities under your account\n"
              "• Do not share your login credentials with others\n"
              "• Use the Forgot Password option if you forget your credentials",
            ),

            _sectionTitle("4. Publishing a Ride (Rider Responsibilities)"),
            _sectionText(
              "When publishing a ride, the rider agrees to:\n\n"
              "• Provide accurate pickup, drop, date, time, and seat availability\n"
              "• Accept or reject booking requests responsibly\n"
              "• Communicate clearly with passengers\n"
              "• Follow all local traffic laws and safety rules\n\n"
              "Book My Car is not responsible for ride cancellations, delays, or disputes between users.",
            ),

            _sectionTitle("5. Booking a Ride (Passenger Responsibilities)"),
            _sectionText(
              "When booking a ride, passengers agree to:\n\n"
              "• Provide correct travel details and passenger count\n"
              "• Respect the rider’s decisions (accept/reject)\n"
              "• Be punctual at the pickup location\n"
              "• Behave respectfully during the journey",
            ),

            _sectionTitle("6. Ride Requests & Status"),
            _sectionText(
              "• Ride requests may be Accepted, Rejected, or Pending\n"
              "• Riders have full control to accept or reject requests\n"
              "• Booking status is visible in My Bookings and History sections\n"
              "• Book My Car does not guarantee ride availability",
            ),

            _sectionTitle("7. Data Privacy & Security"),
            _sectionText(
              "• User data is securely stored using Firebase\n"
              "• We collect only necessary information such as name, email, and ride details\n"
              "• We do not sell or share user data with third parties\n"
              "• Users can request data deletion by deleting their account\n\n"
              "For more details, please refer to our Privacy Policy.",
            ),

            _sectionTitle("8. Account Deletion"),
            _sectionText(
              "• Users can delete their account at any time from Settings\n"
              "• Once deleted, all personal data will be permanently removed\n"
              "• Deleted accounts cannot be recovered",
            ),

            _sectionTitle("9. Prohibited Activities"),
            _sectionText(
              "Users must NOT:\n\n"
              "• Provide false or misleading information\n"
              "• Misuse the platform for illegal activities\n"
              "• Harass, threaten, or abuse other users\n"
              "• Attempt to hack, reverse engineer, or misuse the app\n\n"
              "Violation of these rules may result in permanent account suspension.",
            ),

            _sectionTitle("11. App Availability"),
            _sectionText(
              "• We strive to keep the app available at all times\n"
              "• Temporary downtime may occur due to maintenance or technical issues\n"
              "• We are not responsible for losses due to app unavailability",
            ),

            _sectionTitle("12. Limitation of Liability"),
            _sectionText(
              "Book My Car is not responsible for:\n\n"
              "• Accidents, injuries, or damages during rides\n"
              "• Disputes between riders and passengers\n"
              "• Lost or damaged personal belongings\n"
              "• Delays, cancellations, or missed rides\n\n"
              "Use the app at your own discretion and responsibility.",
            ),

            _sectionTitle("13. Updates to Terms"),
            _sectionText(
              "• These Terms & Conditions may be updated periodically\n"
              "• Users will be notified of significant changes\n"
              "• Continued use of the app means acceptance of updated terms",
            ),

            _sectionTitle("14. Contact Us"),
            _sectionText(
              "If you have any questions or concerns about these Terms, contact us at:\n\n"
              "📧 bookmycar.505425@gmail.com\n"
              "📱 Book My Car",
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ------------------ UI HELPERS ------------------

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _sectionText(String text, {bool isMuted = false}) {
    return Text(
      text,
      style: GoogleFonts.lexend(
        fontSize: 15,
        height: 1.6,
        color: isMuted ? Colors.grey[600] : Colors.black87,
      ),
    );
  }
}
