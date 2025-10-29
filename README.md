# AgoraTalks

A high-performance **Flutter Video Call Application** built using **Agora SDK**, **Provider State Management**, and **SharedPreferences** for local data persistence. The app supports **real-time video calling**, **user authentication**, **profile management**, and **meeting join functionality**, all wrapped in a clean, scalable architecture.

---

## Features

- **User Authentication** — Secure login and registration using APIs.
- **Video Calling** — Real-time, low-latency video calls powered by Agora.
- **Join Meeting** — Easily join ongoing meetings with a meeting ID.
- **State Management** — Efficient app state handling using Provider.
- **Offline Storage** — Persistent data storage with SharedPreferences.
- **Connectivity Handling** — Automatic detection of online/offline status.
- **Profile Management** — Update and maintain user details.
- **Modern UI/UX** — Responsive, clean, and user-friendly interface.

---

## Project Structure

```
lib/
│
├── Business-Logic/                 # Core business logic & state management
│   ├── auth-provider.dart          # Handles authentication logic
│   ├── call_provider.dart          # Manages video call lifecycle and states
│   ├── common-provider.dart        # Shared app-level providers
│   ├── home-provider.dart          # Controls home screen data and actions
│   ├── join_meeting_provider.dart  # Handles meeting joining functionality
│   ├── local_storage.dart          # SharedPreferences-based local caching
│   ├── profile-provider.dart       # Manages user profile updates
│   └── splash-provider.dart        # Splash screen state handler
│
├── data-provider/                  # API and data management layer
│   └── dio-client.dart             # Handles HTTP requests using Dio
│
├── models/                         # Data models
│   └── user_model.dart             # User data model structure
│
├── presentation/                   # UI Layer
│   ├── dialog_box/                 # Custom dialog components
│   │   └── join_meeting_dialog.dart
│   ├── screens/                    # All major app screens
│   ├── utils/                      # Constants and utilities
│   │   ├── appcolors.dart          # App color theme
│   │   └── call_data.dart          # Call-related utilities
│   └── widgets/                    # Reusable UI components
│
├── main.dart                       # App entry point
│
├── linux/, macos/, ios/            # Platform-specific code
└── test/                           # Unit and widget tests
```

---

## Technologies Used

| Category         | Technology                 |
| ---------------- | -------------------------- |
| Framework        | Flutter                    |
| Language         | Dart                       |
| State Management | Provider                   |
| Video SDK        | Agora.io                   |
| Local Storage    | SharedPreferences          |
| HTTP Client      | Dio                        |
| Platform Support | Android, iOS, macOS, Linux |

---

## Architecture Overview

This project follows a **Clean Architecture-inspired structure**:

- **Business-Logic Layer** — Contains `Provider` classes responsible for state and app logic.
- **Data Layer** — Handles network and local data persistence.
- **Presentation Layer** — UI and interaction layer following Flutter’s declarative approach.

Each module is separated to ensure **maintainability**, **testability**, and **scalability**.

---

## Local Storage (SharedPreferences)

Used for storing user session and minimal cached data.

```dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static Future<void> saveUser(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getUser(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
```

---

## Providers

- `AuthProvider` — Manages user login and registration.
- `HomeProvider` — Loads active users and handles connectivity.
- `CallProvider` — Initializes Agora engine and controls call lifecycle.
- `JoinMeetingProvider` — Handles meeting ID validation and joining process.
- `ProfileProvider` — Updates and retrieves user profile data.

---

## Installation & Setup

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/joesaniya/video-app.git
   ```

2. **Install Dependencies:**

   ```bash
   flutter pub get
   ```

3. **Add Environment Variables:**

   AGORA_APP_ID='35f67e0fd1714eb1b8d2dac2081e2c7a'
   BASE_URL= "https://68ff815be02b16d1753e4119.mockapi.io/users/UsersData";

   ```

   ```

4. **Run the App:**

   ```bash
   flutter run
   ```

---

## Contributors

- **Esther Jenslin** — Flutter Developer
