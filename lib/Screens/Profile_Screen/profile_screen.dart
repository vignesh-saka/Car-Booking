import 'dart:io';
import 'package:bookmycar/Screens/Comman/bottom_navigation.dart';
import 'package:bookmycar/Screens/History_Screens/Screens/history_screen.dart';
import 'package:bookmycar/Screens/My_Booking_Screens/Screens/my_bookings_screen.dart';
import 'package:bookmycar/Screens/Publish_Ride_Screens/publishride_screen.dart';
import 'package:bookmycar/Screens/Serach_Screen/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int selectedIndex = 4; // Profile tab selected
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Default user data - Replace with backend data
  String userName = 'Vignesh Kumar Saka';
  String userEmail = 'vigneshkumzr@gmail.com';
  String defaultImagePath =
      'assets/images/default_avatar.png'; // Set your default image path

  void onNavItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PublishRideScreen()),
        );
        break;

      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyBookingsScreen()),
        );
        break;

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchScreen()),
        );
        break;

      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HistoryScreen()),
        );
        break;

      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        break;

      default:
        break;
    }
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Choose Image Source',
            style: GoogleFonts.lexend(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFFFF4444),
                ),
                title: Text('Gallery', style: GoogleFonts.lexend()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFFF4444)),
                title: Text('Camera', style: GoogleFonts.lexend()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });

        // TODO: Upload image to backend
        /*
        await _uploadProfileImage(File(pickedFile.path));
        */

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile picture updated successfully!',
              style: GoogleFonts.lexend(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to pick image: $e',
            style: GoogleFonts.lexend(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ignore: unused_element
  Future<void> _uploadProfileImage(File imageFile) async {
    // TODO: Implement backend upload
    /*
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('YOUR_API_ENDPOINT/upload-profile-image'),
    );
    
    request.files.add(
      await http.MultipartFile.fromPath('profile_image', imageFile.path),
    );
    
    var response = await request.send();
    
    if (response.statusCode == 200) {
      print('Image uploaded successfully');
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFFF3B30),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              // Profile Header Section
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.03,
                  horizontal: screenWidth * 0.06,
                ),
                child: Column(
                  children: [
                    // Title
                    Center(
                      child: Text(
                        'Profile',
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Profile Image with Edit Button
                    Stack(
                      children: [
                        Container(
                          width: screenWidth * 0.28,
                          height: screenWidth * 0.28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _profileImage != null
                                ? Image.file(_profileImage!, fit: BoxFit.cover)
                                : Image.asset(
                                    defaultImagePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback if image not found
                                      return Container(
                                        color: Colors.grey[300],
                                        child: Image(
                                          image: AssetImage(
                                            'assets/images/profile.png',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        // Edit Button
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Container(
                              width: screenWidth * 0.1,
                              height: screenWidth * 0.1,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.edit,
                                color: const Color(0xFFFF4444),
                                size: screenWidth * 0.05,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // User Name
                    Text(
                      userName,
                      style: GoogleFonts.lexend(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),

                    // User Email
                    Text(
                      userEmail,
                      style: GoogleFonts.lexend(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Menu Items
              Expanded(
                child: Container(
                  width: double.infinity,
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
                        icon: Icons.edit_outlined,
                        title: 'Edit Profile',
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        onTap: () {
                          // TODO: Navigate to Edit Profile screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Edit Profile - Coming Soon',
                                style: GoogleFonts.lexend(),
                              ),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.bookmark_outline,
                        title: 'My Bookings',
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        onTap: () {
                          // TODO: Navigate to My Bookings screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyBookingsScreen(),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'My Bookings',
                                style: GoogleFonts.lexend(),
                              ),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.history,
                        title: 'Ride History',
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        onTap: () {
                          // TODO: Navigate to Ride History screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryScreen(),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Ride History',
                                style: GoogleFonts.lexend(),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Sign Out Button
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.06,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _showSignOutDialog();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.018,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Sign Out',
                              style: GoogleFonts.lexend(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFF4444),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05),

                      Text(
                        'App Version 1.0.0',
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.035,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: selectedIndex,
        onItemTapped: onNavItemTapped,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required double screenWidth,
    required double screenHeight,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: screenHeight * 0.008,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: screenWidth * 0.06),
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
              color: Colors.white,
              size: screenWidth * 0.04,
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Sign Out',
            style: GoogleFonts.lexend(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: GoogleFonts.lexend(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.lexend(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement sign out logic
                /*
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/login');
                */
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Signed out successfully',
                      style: GoogleFonts.lexend(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(
                'Sign Out',
                style: GoogleFonts.lexend(
                  color: const Color(0xFFFF4444),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
