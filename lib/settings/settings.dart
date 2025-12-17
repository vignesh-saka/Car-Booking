import 'package:bookmycar/settings/privacy_policy.dart';
import 'package:bookmycar/settings/termsandconditions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookmycar/auth/login_screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white, // ✅ White background
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF3B30),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Settings",
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔴 Red container only for tiles
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
              decoration: const BoxDecoration(
                color: Color(0xFFFF3B30),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.delete_forever,
                    title: "Delete My Account",
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    isDanger: true,
                    onTap: () => _showDeleteAccountDialog(context),
                  ),
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    title: "Terms & Conditions",
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Termsandconditions(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: "Privacy Policy",
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicy(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- MENU TILE ----------------
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required double screenWidth,
    required double screenHeight,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: screenHeight * 0.01,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDanger ? Colors.yellowAccent : Colors.white,
              size: screenWidth * 0.06,
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.lexend(
                  fontSize: screenWidth * 0.042,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: screenWidth * 0.04,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- DELETE CONFIRMATION ----------------
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Delete Account",
          style: GoogleFonts.lexend(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "Are you sure you want to delete your account?\nThis action cannot be undone.",
          style: GoogleFonts.lexend(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("No", style: GoogleFonts.lexend()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAccount(context);
            },
            child: Text(
              "Yes",
              style: GoogleFonts.lexend(
                color: const Color(0xFFFF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- DELETE ACCOUNT LOGIC ----------------
  Future<void> _deleteAccount(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 🔥 Delete Firestore user document
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .delete();

      // 🔥 Delete Firebase Auth account
      await user.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Account deleted successfully",
            style: GoogleFonts.lexend(),
          ),
          backgroundColor: Colors.green,
        ),
      );

      // 🔄 Navigate to Login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to delete account: $e",
            style: GoogleFonts.lexend(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
