# Up Next - Digital Freecycling Platform

## Final Year Project Documentation

### Project Overview

**Up Next** is a mobile application built with Flutter that enables users to practice digital freecycling by listing and discovering unwanted items in their local community. The platform addresses the growing problem of household clutter and unnecessary waste by connecting people who want to give away items they no longer need with those who can put them to good use.

---

## Problem Statement

In modern households, accumulation of unused items has become a significant issue:

- **Space Constraints**: Families often struggle with limited storage space cluttered by items they no longer use
- **Environmental Impact**: Perfectly functional items end up in landfills, contributing to environmental degradation
- **Economic Waste**: Items that could benefit others sit unused while people elsewhere purchase new items
- **Lack of Visibility**: People wanting to give away items lack an easy, localized platform to connect with potential recipients
- **Trust and Safety**: Traditional methods of giving away items (social media, physical notice boards) lack proper verification and location-based features

---

## Solution

Up Next solves these problems by providing:

### Core Features

1. **Item Listings Management**
   - Users can create listings for items they want to give away for free
   - Detailed descriptions with categories (Electronics, Furniture, Clothing, Books, etc.)
   - Location-based listing with interactive map integration
   - Real-time status tracking (Active, Booked, Inactive)

2. **Location-Based Discovery**
   - Browse available items in your local area
   - Interactive map showing exact item locations
   - Address resolution for easy pickup coordination
   - Current location detection and selection

3. **Booking System**
   - Users can book items they're interested in
   - Automatic status updates when items are booked
   - View and manage booked items
   - Cancellation functionality

4. **User Management**
   - Secure authentication with email verification
   - Profile management with location settings
   - Track personal listings and bookings
   - Theme customization (Light/Dark/System)

5. **Safety and Verification**
   - Email verification required for account activation
   - User authentication via Supabase
   - Secure data storage and retrieval

---

## Technologies and Tools Used

### Frontend Framework
- **Flutter** (Dart) - Cross-platform mobile application framework
- **Material Design 3** - Modern UI/UX design system

### Backend and Database
- **Supabase** - Backend-as-a-Service platform
  - PostgreSQL database for data storage
  - Authentication and user management
  - Real-time data synchronization

### State Management and Navigation
- **Provider** - State management solution
  - `ListingProvider` - Manages listing data
  - `UserProvider` - Manages user session
  - `ThemeProvider` - Manages theme preferences
- **GetX** - Navigation and routing

### Location Services
- **Geolocator** - GPS location detection and permissions
- **Geocoding** - Address resolution from coordinates
- **flutter_map** - Interactive map display
- **latlong2** - Geographic coordinate handling
- **MapTiler API** - Map tile provider

### UI Components
- Custom widgets:
  - `CustomButton`
  - `CustomTextfield`
  - `CustomSnackbar`
  - `ListingTile`
  - `ItemLocationMap`

### Local Storage
- **shared_preferences** - Local data persistence for user preferences

### Platform Support
- **Android** (Kotlin)


### Development Tools
- **Gradle** - Android build automation

---

## Architecture

### Application Structure

```
lib/
├── components/          # Reusable UI components
├── helper/             # Utility functions
├── models/             # Data models
│   ├── listing_model.dart    # Listing data structure
│   └── user_model.dart       # User data structure
├── pages/              # Application screens
│   ├── auth_page.dart        # Authentication handler
│   ├── home_page.dart        # Main listing feed
│   ├── profile_page.dart     # User profile
│   ├── create_listing_page.dart
│   ├── listing_details_page.dart
│   ├── user_listings_page.dart
│   ├── booked_listings_page.dart
│   └── item_location_picker_page.dart
├── providers/          # State management
├── repositories/       # Data access layer
├── services/           # Business logic
│   ├── auth_service.dart
│   ├── supabase_service.dart
│   └── user_service.dart
├── app_themes.dart     # Theme configuration
└── main.dart           # Application entry point
```

### Key Services

#### Authentication Service
- User registration with email verification
- Sign in/sign out functionality
- Session management via Supabase Auth

#### Supabase Service
Database operations:
- **Users Table**: User profile data, location information
- **Listings Table**: Item listings with status tracking
- CRUD operations for listings and user data
- Booking and cancellation functionality

#### User Service
- Local user session persistence using SharedPreferences
- User data caching and retrieval

---

## Data Models

### User Model
```dart
- id: String
- username: String
- email: String
- latitude: double?
- longitude: double?
```

### Listing Model
```dart
- id: String
- title: String
- user_id: String
- description: String
- created_at: String
- status: String (active, booked, inactive)
- category: String
- latitude: double
- longitude: double
- booked_by: String?
- booked_at: String?
```

---

## Key Features Implementation

### 1. Location-Based Listing Creation
- Users select item location via interactive map
- Current location detection with permission handling
- Address resolution using geocoding API
- Location stored with listing in database

### 2. Real-time Listing Feed
- Pull-to-refresh functionality
- Listings exclude current user's own items
- Status indicators (Active/Booked/Inactive)
- Navigate to detailed view for more information

### 3. Booking Workflow
1. User browses available listings
2. Views detailed information
3. Confirms booking via dialog
4. Status updates automatically in database
5. Booked items appear in user's booked items list

### 4. Profile Management
- Location services integration with GPS
- Update user location
- View number of personal listings and booked items
- Theme customization (System/Light/Dark)

---

## Security Features

1. **Email Verification**: Users must verify email before accessing app
2. **Authentication State Management**: Handles routing based on auth state
3. **Secure API Keys**: Environment variables stored securely
4. **Row-Level Security**: Implemented through Supabase policies

---

## User Interface

### Theme System
- Light and dark themes with consistent styling
- Primary color: Indigo (#6366F1)
- Secondary color: Bright blue (#60A5FA)
- Consistent Material Design 3 components
- Persistent theme selection

### Custom Components
- **CustomSnackbar**: Contextual feedback with types (error, success, warning, info)
- **CustomButton**: Consistent button styling across app
- **CustomTextfield**: Reusable input fields with validation
- **ListingTile**: Card-based listing display with user info and actions

---

## Navigation Structure

Main routes:
```
/auth → Authentication handler
/login → Login screen
/signup → Registration screen
/home → Main listing feed
/profile → User profile
/create_listing → Create new listing
/pick_location → Location picker
/user_listings → User's own listings
/manage_listings → Manage/delete listings
/booked_listings → Items user has booked
/verification_pending → Email verification screen
```

---

## Database Schema

### Users Table
- `id` (UUID, Primary Key)
- `email` (Text, Unique)
- `username` (Text)
- `latitude` (Numeric, Nullable)
- `longitude` (Numeric, Nullable)

### Listings Table
- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key → Users)
- `title` (Text)
- `description` (Text)
- `category` (Text)
- `status` (Text: active/booked/inactive)
- `latitude` (Numeric)
- `longitude` (Numeric)
- `created_at` (Timestamp)
- `booked_by` (UUID, Nullable, Foreign Key → Users)
- `booked_at` (Timestamp, Nullable)

---

## Future Enhancements

1. **In-app Messaging**: Direct communication between users
2. **Image Upload**: Add photos to listings
3. **Search and Filters**: Category-based filtering, distance-based search
4. **Rating System**: User reputation and feedback
5. **Push Notifications**: Alerts for new nearby listings
6. **Social Features**: User profiles, activity feed

---

## Installation and Setup

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Supabase account

### Configuration
1. Clone the repository
2. Update Supabase credentials in `lib/main.dart`:
   ```dart
   await Supabase.initialize(
     url: 'YOUR_SUPABASE_URL',
     anonKey: 'YOUR_SUPABASE_ANON_KEY',
   );
   ```
3. Configure MapTiler API key in `lib/env.dart`
4. Run `flutter pub get` to install dependencies
5. Run `flutter run` to launch the app

---

## Dependencies

Key packages from `pubspec.yaml`:
- `flutter_map`: ^7.0.2
- `latlong2`: ^0.9.1
- `geolocator`: ^13.0.1
- `geocoding`: ^3.0.0
- `supabase_flutter`: ^2.8.1
- `provider`: ^6.1.2
- `get`: ^4.6.6
- `shared_preferences`: ^2.3.3
- `intl`: ^0.20.1

---

## Conclusion

Up Next demonstrates a practical solution to the problem of household clutter and waste by leveraging modern mobile technology and location-based services. The application successfully combines intuitive UI/UX design with robust backend infrastructure to create a seamless freecycling experience. By making it easy for users to give away and discover free items in their local community, Up Next promotes sustainable consumption patterns and reduces environmental impact.

The project showcases proficiency in:
- Cross-platform mobile development with Flutter
- Backend integration with Supabase
- Real-time location services and mapping
- State management and navigation patterns
- User authentication and security
- Responsive UI design with Material Design 3

---

## License

This project is part of an academic final year project.
