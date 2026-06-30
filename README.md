# Book My Car 🚗

A comprehensive Flutter application for booking and publishing car rides, designed to offer a seamless and user-friendly carpooling and ride-sharing experience.

## Features ✨

- **User Authentication**: Secure Login, Sign up, and Password Recovery using Firebase Auth.
- **Google Sign-In**: Quick and easy authentication with Google accounts.
- **Publish Rides**: Users can easily publish their available rides with route, timing, and vehicle details.
- **Search & Find Rides**: Search for available rides based on your destination and preferences.
- **Booking System**: Book rides conveniently and manage your current bookings.
- **Ride History**: Keep track of your past trips and published rides.
- **User Profile**: Manage user profiles, including profile pictures using Firebase Storage and Image Picker.
- **Push Notifications**: Real-time updates and notifications using Firebase Cloud Messaging (FCM).
- **Connectivity Check**: Built-in internet connection checker for a smoother and robust user experience.

## Tech Stack 🛠️

- **Framework**: [Flutter](https://flutter.dev/) (SDK ^3.9.0)
- **Backend & Database**: Firebase (Authentication, Cloud Firestore, Cloud Storage)
- **Push Notifications**: Firebase Cloud Messaging (FCM) & Flutter Local Notifications
- **Additional Tools**: Google Fonts, Share Plus, URL Launcher, Badges

## Getting Started 🚀

### Prerequisites

- Flutter SDK
- Android Studio / VS Code
- A Firebase project with Auth, Firestore, Storage, and Messaging enabled.

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd Car-Booking
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup:**
   - Configure Firebase for your project using the `flutterfire` CLI or by manually adding `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
   - Enable Authentication methods (Email/Password & Google Sign-In) in your Firebase Console.
   - Setup Cloud Firestore and Firebase Storage.

4. **Run the App:**
   ```bash
   flutter run
   ```

## Folder Structure 📁

- `lib/auth/`: Authentication screens (Login, Signup, Forgot Password).
- `lib/Screens/`: Core application screens (Search, Publish Ride, Available Rides, Bookings, History, Profile).
- `lib/pages/`: Entry screens including the Splash Screen.
- `lib/controllers/`: Application logic, including the Notification Controller.
- `lib/widgets/`: Reusable UI components.
- `lib/settings/`: Application settings and configurations.

## Contributing 🤝

Contributions, issues, and feature requests are welcome! Feel free to check the issues page if you want to contribute.

---
Developed with ❤️ using Flutter.
