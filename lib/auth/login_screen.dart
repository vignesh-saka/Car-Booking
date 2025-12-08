import 'package:bookmycar/Screens/Serach_Screen/search_screen.dart';
import 'package:bookmycar/auth/forgotPassword_screen.dart';
import 'package:bookmycar/auth/signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  // --------------------------------------------------
  // 🔔 Send "Account Created" email only once per user
  // --------------------------------------------------
  Future<void> _sendWelcomeEmailIfNeeded(User user) async {
    final usersRef = FirebaseFirestore.instance.collection("users");
    final userDocRef = usersRef.doc(user.uid);
    final userDoc = await userDocRef.get();

    if (!userDoc.exists) return;

    final data = userDoc.data() ?? {};
    final bool alreadySent = data["welcomeEmailSent"] == true;

    if (alreadySent) return;

    final String email = (data["email"] ?? user.email ?? "").toString().trim();
    final String name =
        (data["name"] ?? user.displayName ?? "there").toString().trim();

    if (email.isEmpty) return;

    // 👉 Trigger email via Firebase Extension
    await FirebaseFirestore.instance.collection('mail').add({
      'to': email,
      'message': {
        'subject': 'Welcome to Book My Car 🚗',
        'text': 'Hi $name,\n\n'
            'Your Book My Car account has been created and you have logged in successfully.\n\n'
            'You can now publish rides, book rides and manage your trips easily.\n\n'
            'Happy travelling!\nBook My Car Team',
        'html': '<p>Hi $name,</p>'
            '<p>Your <b>Book My Car</b> account has been created and you have logged in successfully.</p>'
            '<p>You can now publish rides, book rides and manage your trips easily.</p>'
            '<p>Happy travelling!<br/>Book My Car Team</p>',
      },
    });

    // Mark as sent
    await userDocRef.update({
      "welcomeEmailSent": true,
      "welcomeEmailSentAt": FieldValue.serverTimestamp(),
    });
  }

  // --------------------------------------------------
  // 🔥 Firebase Email/Password Login Function
  // --------------------------------------------------
  Future<void> loginUser() async {
    setState(() => _isLoading = true);

    try {
      UserCredential credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = credential.user;

      // 🔔 Send welcome email on FIRST login
      if (user != null) {
        await _sendWelcomeEmailIfNeeded(user);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Successful!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SearchScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Invalid Credentials"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --------------------------------------------------
  // 🔥 Google Sign-In for Login
  // --------------------------------------------------
  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _isGoogleLoading = true;
      });

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user == null) throw Exception("Google sign-in failed: user is null");

      final usersRef = FirebaseFirestore.instance.collection("users");
      final userDoc = await usersRef.doc(user.uid).get();

      if (!userDoc.exists) {
        await usersRef.doc(user.uid).set({
          "uid": user.uid,
          "name": user.displayName ?? "",
          "email": user.email ?? "",
          "photoUrl": user.photoURL,
          "authProvider": "google",
          "createdAt": DateTime.now(),
        });
      }

      // 🔔 Send welcome email on FIRST Google login
      await _sendWelcomeEmailIfNeeded(user);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Logged in with Google successfully!",
            style: GoogleFonts.lexend(),
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SearchScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Google sign-in failed: $e",
            style: GoogleFonts.lexend(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔴 Red Container (card)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFFF3B30),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: height * 0.08),
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.lexend(
                              color: Colors.white,
                              fontSize: height * 0.022,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              const TextSpan(text: "Book "),
                              TextSpan(
                                text: "Car",
                                style: GoogleFonts.lexend(
                                  fontSize: height * 0.03,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const TextSpan(text: "\nat your "),
                              TextSpan(
                                text: "Fingertips",
                                style: GoogleFonts.lexend(
                                  fontWeight: FontWeight.bold,
                                  fontSize: height * 0.027,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.05),
                      Text(
                        "Login",
                        style: GoogleFonts.lexend(
                          fontSize: height * 0.027,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: height * 0.03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Email Address",
                          style: GoogleFonts.lexend(
                            fontSize: height * 0.018,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.008),
                      TextFormField(
                        controller: _emailController,
                        style: GoogleFonts.lexend(fontSize: height * 0.018),
                        decoration: InputDecoration(
                          hintText: "Enter Email Address",
                          hintStyle: GoogleFonts.lexend(
                            color: Colors.grey.shade600,
                            fontSize: height * 0.018,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: height * 0.016,
                            horizontal: width * 0.04,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          errorStyle: GoogleFonts.lexend(
                            color: Colors.white,
                            fontSize: height * 0.016,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email";
                          } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                              .hasMatch(value)) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: height * 0.02),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Password",
                          style: GoogleFonts.lexend(
                            fontSize: height * 0.018,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.008),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: GoogleFonts.lexend(fontSize: height * 0.018),
                        decoration: InputDecoration(
                          hintText: "Enter Password",
                          hintStyle: GoogleFonts.lexend(
                            color: Colors.grey.shade600,
                            fontSize: height * 0.018,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: height * 0.016,
                            horizontal: width * 0.04,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          errorStyle: GoogleFonts.lexend(
                            color: Colors.white,
                            fontSize: height * 0.016,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey.shade700,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your password";
                          } else if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: height * 0.008),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Forgot password?",
                            style: GoogleFonts.lexend(
                              color: Colors.white,
                              fontSize: height * 0.016,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.025),
                      SizedBox(
                        width: double.infinity,
                        height: height * 0.055,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    loginUser();
                                  }
                                },
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Color(0xFFFF3B30),
                                )
                              : Text(
                                  "Login",
                                  style: GoogleFonts.lexend(
                                    color: const Color(0xFFFF3B30),
                                    fontWeight: FontWeight.bold,
                                    fontSize: height * 0.022,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          ),
                          child: RichText(
                            text: TextSpan(
                              text: "Don’t have an account? ",
                              style: GoogleFonts.lexend(
                                color: Colors.white,
                                fontSize: height * 0.018,
                              ),
                              children: [
                                TextSpan(
                                  text: "SignUp",
                                  style: GoogleFonts.lexend(
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.06),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: height * 0.03),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.black54)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "or sign in with",
                    style: GoogleFonts.lexend(
                      color: Colors.black87,
                      fontSize: height * 0.016,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.black54)),
              ],
            ),
            SizedBox(height: height * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.15),
              child: SizedBox(
                width: double.infinity,
                height: height * 0.055,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                  child: _isGoogleLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: height * 0.035,
                              height: height * 0.035,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.asset(
                                  'assets/images/google_logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(width: width * 0.03),
                            Text(
                              'Sign in with Google',
                              style: GoogleFonts.lexend(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: height * 0.018,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            SizedBox(height: height * 0.04),
            Text(
              "2025 @ Book My Car",
              style: GoogleFonts.lexend(
                fontSize: height * 0.016,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: height * 0.02),
          ],
        ),
      ),
    );
  }
}
