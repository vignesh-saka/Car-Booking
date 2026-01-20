import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF3B30),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Privacy Policy",
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
            _sectionText("Last updated: 12/17/2025", isMuted: true),
            const SizedBox(height: 16),

            _sectionText(
              "Book My Car (“we”, “our”, “us”) respects your privacy and is committed "
              "to protecting your personal information. This Privacy Policy explains "
              "how we collect, use, store, and protect user data when you use our "
              "mobile application.\n\n"
              "By using Book My Car, you agree to the practices described in this "
              "Privacy Policy.",
            ),

            _sectionTitle("1. Information We Collect"),

            _subTitle("a. Personal Information"),
            _sectionText(
              "• Full Name\n"
              "• Email Address\n"
              "• Login credentials (via Email/Password or Google Sign-In)",
            ),

            _subTitle("b. Ride & Booking Information"),
            _sectionText(
              "• Pickup location\n"
              "• Drop location\n"
              "• Travel date and time\n"
              "• Number of passengers\n"
              "• Ride requests and booking status (Requested / Accepted / Rejected)",
            ),

            _subTitle("c. Technical Information"),
            _sectionText(
              "• Basic device information\n"
              "• App usage data (for improving performance)\n"
              "• Firebase-generated identifiers\n\n"
              "We do not collect sensitive personal data such as Aadhaar, PAN, bank "
              "details, or passwords in plain text.",
            ),

            _sectionTitle("2. How We Use Your Information"),
            _sectionText(
              "We use your data to:\n\n"
              "• Create and manage user accounts\n"
              "• Enable ride publishing and booking\n"
              "• Display ride history and booking status\n"
              "• Improve app functionality and user experience\n"
              "• Ensure platform security\n"
              "• Communicate essential app-related updates\n\n"
              "We do not use your data for advertising.",
            ),

            _sectionTitle("3. Authentication & Google Sign-In"),
            _sectionText(
              "• Google Sign-In is used only for authentication\n"
              "• We receive basic profile information (name, email)\n"
              "• We do not access your Google contacts, photos, or files",
            ),

            _sectionTitle("4. Data Storage & Security"),
            _sectionText(
              "• All data is securely stored using Firebase services\n"
              "• Industry-standard security rules are applied\n"
              "• Data access is restricted based on user authentication\n"
              "• We continuously improve security measures to prevent unauthorized access",
            ),

            _sectionTitle("5. Data Sharing"),
            _sectionText(
              "We do not sell, rent, or trade user data.\n\n"
              "Data is shared only when required:\n\n"
              "• Between riders and passengers for booking purposes\n"
              "• With Firebase services for app operation\n"
              "• When required by law or legal authorities",
            ),

            _sectionTitle("6. User Control & Rights"),
            _sectionText(
              "Users have full control over their data.\n\n"
              "You can:\n\n"
              "• View your personal details in the Profile section\n"
              "• Update allowed information\n"
              "• Delete your account at any time",
            ),

            _sectionTitle("7. Account Deletion & Data Removal"),
            _sectionText(
              "• Users can permanently delete their account from Settings\n"
              "• Once deleted, all personal data is removed from our database\n"
              "• Deleted data cannot be recovered",
            ),

            _sectionTitle("8. Cookies & Tracking"),
            _sectionText(
              "• Book My Car does not use cookies\n"
              "• We do not track users across other apps or websites",
            ),

            _sectionTitle("9. Children’s Privacy"),
            _sectionText(
              "• Book My Car is not intended to knowingly collect data from children\n"
              "• Minors are advised to use the app under parental or guardian supervision\n"
              "• If we become aware of unintended data collection from minors, "
              "we will delete it immediately",
            ),

            _sectionTitle("10. Third-Party Services"),
            _sectionText(
              "We use trusted third-party services:\n\n"
              "• Firebase Authentication\n"
              "• Cloud Firestore\n"
              "• Firebase Storage\n\n"
              "These services follow their own privacy and security standards.",
            ),

            _sectionTitle("11. Changes to This Privacy Policy"),
            _sectionText(
              "• We may update this Privacy Policy from time to time\n"
              "• Any changes will be reflected within the app\n"
              "• Continued use of the app means acceptance of the updated policy",
            ),

            _sectionTitle("12. Data Retention"),
            _sectionText(
              "• User data is stored only as long as the account is active\n"
              "• Inactive or deleted accounts will have their data removed",
            ),

            _sectionTitle("13. Legal Compliance"),
            _sectionText(
              "We comply with applicable data protection laws and "
              "Google Play Developer policies.",
            ),

            _sectionTitle("14. Contact Us"),
            _sectionText(
              "If you have questions or concerns about this Privacy Policy, "
              "contact us at:\n\n"
              "📧 bookmycar.505425@gmail.com\n"
              "📱 Book My Car",
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ---------------- UI HELPERS ----------------

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

  Widget _subTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
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
