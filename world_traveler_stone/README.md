# 🗺️ World Traveler Stone

A Flutter application for tracking the journey of physical stones with QR codes around the world.

## 📱 Overview

World Traveler Stone is a unique mobile application that turns ordinary stones into global travelers. Each stone has a unique QR code, and users can scan, move, and track these stones as they journey across the world.

## ✨ Features

### ✅ Implemented Features

#### 🔐 Phase 1: Authentication & Registration
- Firebase Authentication integration
- Email/password login and registration
- GDPR compliant user consent
- Automatic auth state management

#### 📱 Phase 2: QR Code System
- QR code generation for stones
- Camera-based QR scanning
- Stone validation and tracking
- Detailed stone history view
- Photo attachments to stone history

#### 📍 Phase 3: GPS & Localization
- Real-time GPS location tracking
- Geocoding (address from coordinates)
- Country detection
- Move validation (5km minimum, 24h cooldown)
- Photo upload to Firebase Storage
- Story attachment to moves

#### 🗺️ Phase 4: Interactive Map
- Google Maps integration
- Real-time stone markers
- Stone filtering (all, active, lost, my stones)
- Route visualization with polylines
- Bottom sheet stone details
- User location centering

#### 🔔 Phase 5: Notifications
- Local notifications
- Firebase Cloud Messaging (FCM)
- Stone nearby alerts
- Stone found notifications

#### 💎 Phase 6: Diamond Reward System
- Earn diamonds for actions:
  - 50 💎 for finding a stone
  - 100 💎 for moving a stone
  - 300 💎 for international moves
  - 50 💎 for sharing stories with photos
  - 500 💎 for finding lost stones
- Diamond history tracking
- Real-time balance updates

#### 📊 Phase 7: Statistics
- Stone statistics (distance, countries, owners)
- User statistics (stones found, moved, countries visited)
- Leaderboards (diamonds, distance, countries)
- Personal achievement tracking

## 🏗️ Project Structure

```
lib/
├── models/
│   ├── user_model.dart           # User and DiamondTransaction models
│   ├── stone_model.dart          # Stone and LocationHistory models
│   └── statistics_model.dart     # Statistics and Leaderboard models
├── services/
│   ├── auth_service.dart         # Firebase authentication
│   ├── stone_service.dart        # Stone management
│   ├── qr_service.dart           # QR code operations
│   ├── location_service.dart     # GPS and geocoding
│   ├── storage_service.dart      # Firebase Storage
│   ├── diamond_service.dart      # Diamond rewards
│   ├── notification_service.dart # Local notifications
│   ├── fcm_service.dart          # Push notifications
│   └── statistics_service.dart   # Statistics calculations
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── auth_wrapper.dart
│   ├── home/
│   │   └── home_screen.dart      # Main navigation
│   ├── map/
│   │   └── map_screen.dart       # Interactive map
│   ├── qr/
│   │   └── qr_scanner_screen.dart
│   ├── stone/
│   │   ├── stone_detail_screen.dart
│   │   └── move_stone_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── utils/
│   └── stone_validation_util.dart
└── main.dart
```

## 🛠️ Technologies Used

- **Framework**: Flutter 3.0+
- **Backend**: Firebase
  - Authentication
  - Cloud Firestore
  - Cloud Storage
  - Cloud Messaging
- **Maps**: Google Maps Flutter
- **Location**: Geolocator, Geocoding
- **QR Codes**: mobile_scanner, qr_flutter
- **Notifications**: flutter_local_notifications

## 📦 Dependencies

See `pubspec.yaml` for complete list. Key dependencies:
- firebase_core, firebase_auth, cloud_firestore
- google_maps_flutter
- geolocator, geocoding
- mobile_scanner, qr_flutter
- image_picker
- flutter_local_notifications

## 🚀 Getting Started

### Prerequisites

1. Flutter SDK (>=3.0.0)
2. Firebase project
3. Google Maps API key

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd world_traveler_stone
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
- Create a Firebase project
- Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- Place them in appropriate directories
- Generate `firebase_options.dart` using FlutterFire CLI

4. Configure Google Maps
- Get a Google Maps API key
- Add it to `android/app/src/main/AndroidManifest.xml`
- Add it to `ios/Runner/AppDelegate.swift`

5. Run the app
```bash
flutter run
```

## 📋 Game Mechanics

### Stone Movement Rules
- **Minimum Distance**: 5 km between moves
- **Cooldown**: 24 hours between moves
- **Location Tracking**: Automatic GPS capture
- **Photo & Story**: Optional but rewarded

### Diamond Economy
- **Finding Stone**: 50 💎
- **Moving Stone**: 100 💎
- **International Move**: +300 💎
- **Story + Photo**: +50 💎
- **Finding Lost Stone**: 500 💎

## 🎯 Future Enhancements

- Wheel of Fortune mini-game
- E-shop integration for physical rewards
- Augmented Reality stone viewing
- Social features and stone trading
- Offline mode support
- More gamification features

## 📄 License

This project is licensed under the MIT License.

## 👥 Contributing

Contributions are welcome! Please feel free to submit pull requests.

## 📧 Contact

For questions or support, please open an issue on GitHub.

---

Made with ❤️ using Flutter and Firebase
