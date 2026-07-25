import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // ১. এই ফাইলটি ইমপোর্ট করা হয়েছে

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ২. Web-এর জন্য options যুক্ত করা হয়েছে
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BMI Tracker',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black87),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E1E1E), foregroundColor: Colors.white),
      ),
      home: FirebaseAuth.instance.currentUser != null ? const HomeScreen() : const LoginScreen(),
    );
  }
}