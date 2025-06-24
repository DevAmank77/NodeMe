# NodeMe 🌐(Hangout App project by Google Developers Student Club IIT ROORKEE)

NodeMe is a mobile social networking app that allows users to connect with friends and friends-of-friends (1st and 2nd-degree connections), send friend requests, create hangouts, and request approvals through mutual friends. Built with **Flutter**, it leverages **Firebase Realtime Database**, **Firestore**, and **Supabase Storage** for a seamless social experience.

## 🚀 Features

* 👤 User Authentication (Firebase Auth)
* 📝 Profile Setup and Editing
* 🢑 Friend Requests (Realtime Database)
* 🔗 Mutual Friends & 1st-Degree Connection Logic
* 🡆 Create and Join Hangouts (Firestore)
* ✅ Owner & Mutual Friend Approval Flow
* 📩 Notification System with Real-Time Counts
* 📷 Profile Picture Upload (Supabase)

---

## 🧱 Tech Stack

| Layer             | Technology                    |
| ----------------- | ----------------------------- |
| UI Framework      | Flutter                       |
| Authentication    | Firebase Auth                 |
| User Data         | Firestore                     |
| Friend & Graph DB | Firebase Realtime Database    |
| Media Storage     | Supabase Storage              |
| State Management  | `setState` / Stateful Widgets |
| Package Manager   | pub.dev                       |

---

## 🧽 App Structure

```
lib/
|- models/             # User model and data classes
|- screens/            # UI screens (Home, Profile, Edit, Notifications)
|- widgets/            # Reusable components (buttons, image pickers)
|- resources/          # Services like FriendService, Firestore access
|- main.dart           # App entry point
```

---

## 🔧 Setup Instructions

1. Clone the repository:

```bash
git clone https://github.com/yourusername/nodeme.git
cd nodeme
```

2. Install dependencies:

```bash
flutter pub get
```

3. Add your Firebase config files:

* `android/app/google-services.json`
* `ios/Runner/GoogleService-Info.plist`

4. Setup Supabase Bucket:

* Create a bucket named `images` in your Supabase project
* Allow public read access

5. Run the app:

```bash
flutter run
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    cupertino_icons: ^1.0.8
    firebase_core: ^2.30.0
    firebase_auth: ^4.17.3
    google_sign_in: ^6.2.1
    cloud_firestore: ^4.17.5
    firebase_database: ^10.4.5
    google_fonts: ^6.2.1
    image_picker: ^1.1.2
    supabase_flutter: ^2.9.1
    graphview: ^1.2.0
```

---

## 🔄 TODOs / Future Improvements

* 💡 Better graph-based UI for 2nd-degree connections
* 🔍 Search & discover users by interest
* 🔐 Enhanced friend recommendation engine
* ⬆️ Push notifications
* 🏢 Add friends only from the same college

---

## 👤 Developer

* Name: Aman Kumar
* GitHub: https://github.com/DevAmank77/NodeMe.git
* Email: amankumargond772004@gmail.com

---

👌 *This project is submitted for academic/project verification purposes.*
