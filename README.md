# 🏋️ Fitness & Calorie Tracker (BMI Calculator v2.0)

A comprehensive Flutter-based mobile application designed to calculate Body Mass Index (BMI), track daily food calorie intake, monitor workout burn rates, manage water/sleep logs, and visualize health trends in real time. Built on top of a simple BMI calculator, the app has evolved into a full health-tracking companion with Firebase-powered cloud sync.

---

## 📌 Project Information

**Course:** Mobile Application Development
**Version:** v2.0

### Developed By

| Name | ID |
|---|---|
| Priya Biswas | 232072087 |
| Ali Hosain Raunok | 232071063 |

---

## ✨ Detailed Features

- **User Authentication & Profile Sync** — Secure user registration, login, and real-time profile data synchronization via Firebase Authentication and Firestore.
- **Instant BMI Calculation & Categories** — Computes precise Body Mass Index based on height and weight inputs, instantly classifying results into Underweight, Normal Weight, Overweight, or Obese, with ideal weight range suggestions.
- **Personalized Health Recommendations** — Tailored tips and guidance based on the user's BMI category and goals.
- **Workout & Exercise Logging** — Track various physical activities (Running, Cycling, Swimming, Gym, Walking) with automatic calorie burn calculations.
- **Food Calorie Database & Net Balance** — Quick-select common meals from a built-in database to record calorie intake and track daily net calories (`Intake - Burned`).
- **Water & Sleep Trackers** — Interactive circular progress rings for monitoring daily water hydration goals and dedicated input fields for sleep duration tracking.
- **Streak Counter & Daily Health Tips** — Gamified consistency tracker showing active streak days alongside daily health and nutrition tips.
- **1-Click Quick Actions** — Convenient action chips on the dashboard for instant logging (+1 Glass Water, +200 kcal Snack, +15 Min Walk, 8h Sleep).
- **BMI & Activity History** — Save BMI records and workout/calorie logs to Firestore and view previous entries at any time.
- **Interactive Visual History & Analytics** — View historical logs, trends, and charts for BMI records and calorie burn metrics over time.
- **Dynamic Dark/Light Mode** — Full-app theme toggle powered by Provider for comfortable viewing day or night.

---

## 🧮 BMI Formula

```
BMI = weight (kg) / [height (m)]²
```

---

## 📊 BMI Categories Reference

| BMI Range | Category |
|---|---|
| BMI < 18.5 | Underweight |
| 18.5 – 24.9 | Normal Weight |
| 25 – 29.9 | Overweight |
| BMI ≥ 30 | Obese |

---

## 🛠️ Technologies Used

- **Framework:** Flutter & Dart
- **State Management:** Provider
- **Backend & Database:** Firebase Authentication, Cloud Firestore
- **Development Tools:** Android Studio, VS Code

---

## 📱 Platform Compatibility

- Android Devices (Android 10 or Above)

---

## ⚙️ Functional & Non-Functional Requirements

### Functional Requirements
- User registration and secure login system via email/password.
- Input height, weight, and target weight goals.
- Calculate and display accurate BMI results and health categories.
- Display personalized health recommendations based on BMI category.
- Record and manage workout activity sessions and burned calories.
- Track daily water intake, calorie consumption, and sleep duration.
- Save and retrieve historical BMI and activity records from Firebase Firestore.
- Toggle between light and dark themes dynamically.

### Non-Functional Requirements
- Fast performance and responsive layout across screen sizes.
- Intuitive, user-friendly Material 3 interface design.
- Secure cloud data storage and real-time synchronization.
- Smooth Android compatibility and reliable user experience.

---

## 🖥️ User Interface Screens

- Registration & Login Screens
- Main Dashboard & Home Screen (BMI Calculator, Quick Actions, Progress Rings, Tips)
- BMI Result & Health Recommendation Screen
- Workout & Activity Tracking Panel
- History Screen & Visual Analytics Charts (BMI history, calorie/workout logs)
- User Profile & Goal Management Screen

---

## 🎯 Project Objectives

- Build a feature-rich, user-friendly Flutter application expanding beyond basic BMI calculations.
- Implement accurate and reliable BMI calculation logic.
- Implement robust health tracking modules (Calories, Workouts, Sleep, Water).
- Store and synchronize user data seamlessly using Firebase cloud services.
- Provide clear visual analytics and historical tracking for fitness goals.
- Ensure optimal performance and clean architectural structure.

---

## 🚀 Installation & Getting Started

### 1. Clone the Repository

```bash
git clone <your-repository-link>
cd fitness-tracker-app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Configuration

- Create a project on the [Firebase Console](https://console.firebase.google.com/).
- Enable **Authentication** (Email/Password) and **Cloud Firestore**.
- Register your Android app and place the downloaded `google-services.json` file inside the `android/app/` directory.

### 4. Run the Application

```bash
flutter run
```

---

## 📜 License

This project is developed for academic purposes under the Mobile Application Development course.
