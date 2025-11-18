import 'package:bookmycar/auth/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // -------------------------
  // 🔥 Firebase SignUp Method
  // -------------------------
  Future<void> registerUser() async {
    setState(() => _isLoading = true);

    try {
      // 1️⃣ Create user in Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // 2️⃣ Save user details in Firestore
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "uid": uid,
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "createdAt": DateTime.now(),
      });

      // 3️⃣ Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account Created Successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // 4️⃣ Navigate to Login Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Something went wrong"),
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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔴 Red Container
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

                      // TITLE
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
                        "Sign Up",
                        style: GoogleFonts.lexend(
                          fontSize: height * 0.027,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: height * 0.03),

                      // NAME FIELD
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Name",
                          style: GoogleFonts.lexend(
                            fontSize: height * 0.018,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.008),

                      TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.lexend(fontSize: height * 0.018),
                        decoration: InputDecoration(
                          hintText: "Enter Your Name",
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
                        validator: (value) =>
                            value!.trim().isEmpty ? "Please enter your name" : null,
                      ),

                      SizedBox(height: height * 0.02),

                      // EMAIL FIELD
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

                      // PASSWORD FIELD
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
                            return "Please enter a password";
                          } else if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: height * 0.04),

                      // SIGN UP BUTTON
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
                                    registerUser();
                                  }
                                },
                          child: _isLoading
                              ? Text(
                                  "Loading...",
                                  style: GoogleFonts.lexend(
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                    fontWeight: FontWeight.bold,
                                    fontSize: height * 0.020,
                                  ),
                                )
                              : Text(
                                  "Sign Up",
                                  style: GoogleFonts.lexend(
                                    color: const Color(0xFFFF3B30),
                                    fontWeight: FontWeight.bold,
                                    fontSize: height * 0.022,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: height * 0.02),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: GoogleFonts.lexend(
                              color: Colors.white,
                              fontSize: height * 0.018,
                            ),
                            children: [
                              TextSpan(
                                text: "Login",
                                style: GoogleFonts.lexend(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
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
