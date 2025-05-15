# Hotel Management System

A Flutter application for hotel booking management with Firebase authentication.

## Framework & Dependencies

- Flutter SDK
- Firebase Auth
- Provider State Management
- SharedPreferences
- ScreenUtil for responsive design

## Required Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  provider: ^6.0.5
  shared_preferences: ^2.2.2
  flutter_screenutil: ^5.9.0
  intl: ^0.19.0
```

## Installation & Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd neoai_assessment
```

2. Get Flutter dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a new Firebase project
   - Add your `google-services.json` to `android/app/`
   - Add your `GoogleService-Info.plist` to `ios/Runner/`
   - Update web/index.html with your Firebase config

4. Run the project:
```bash
# For Chrome
flutter run -d chrome --web-renderer html

# For Android
flutter run -d android

# For iOS
flutter run -d ios
```

## Project Structure

```
lib/
├── configs/
│   ├── app_theme.dart
│   └── context_extensions.dart
├── modules/
│   ├── logins/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── services/
│   │   └── firebase_auth_services.dart
│   └── home_screen.dart
└── main.dart
```

## Features

- Firebase Authentication (Email/Password)
- Google & Apple Sign-in (Coming soon)
- Booking Management
- Staff Management
- Room Management
- Responsive Design
- Dark/Light Theme Support

## Environment Setup

Minimum requirements:
- Flutter SDK: 3.0.0 or higher
- Dart SDK: 2.17.0 or higher
- Android Studio / VS Code
- Android SDK for Android deployment
- Xcode for iOS deployment

## Development

To run the project in development mode:

```bash
flutter run --flavor development
```

## Build & Release

For production build:

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.