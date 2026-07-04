import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Handles user data and logout
import '../widgets/input_field.dart';
import 'login_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  String result = "";
  String category = "";
  Color resultColor = Colors.indigo;

  // Pull the current active session directly from Firebase
  final User? currentUser = FirebaseAuth.instance.currentUser;

  void calculateBMI() {
    // Defense check: gracefully stop if fields are left blank
    if (heightController.text.isEmpty || weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in both fields first!")),
      );
      return;
    }

    double? height = double.tryParse(heightController.text);
    double? weight = double.tryParse(weightController.text);

    if (height == null || weight == null || height <= 0 || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid metrics.")),
      );
      return;
    }

    // Standard BMI Calculation Formula
    double bmi = weight / ((height / 100) * (height / 100));

    String cat;
    Color color;

    if (bmi < 18.5) {
      cat = "Underweight";
      color = Colors.blue.shade600;
    } else if (bmi < 25) {
      cat = "Normal Weight";
      color = Colors.green.shade600;
    } else if (bmi < 30) {
      cat = "Overweight";
      color = Colors.orange.shade600;
    } else {
      cat = "Obese";
      color = Colors.red.shade600;
    }

    setState(() {
      result = bmi.toStringAsFixed(1);
      category = cat;
      resultColor = color;
    });
  }

  void handleSignOut() async {
    try {
      // 1. Terminate the session on Firebase
      await FirebaseAuth.instance.signOut();

      // 2. Performance check: verify user hasn't closed the screen during the async wait
      if (!mounted) return;

      // 3. Clear stack and redirect to Login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()), // <-- Replace with your exact Login widget name
            (route) => false, // This line wipes out the back-button history completely
      );

      /*
    NOTE: If your project uses Named Routes instead, comment out the code above
    and use this single line instead:

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    */

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to log out: $e")),
      );
    }
  }

  String _getInsightMessage(String category) {
    switch (category) {
      case "Underweight":
        return "You're below the ideal range. Ensure you're getting adequate nutrition.";
      case "Normal Weight":
        return "Excellent! You're exactly where you need to be. Keep up the active lifestyle.";
      case "Overweight":
        return "Slightly above the recommended range. A balanced diet and exercise can assist.";
      case "Obese":
        return "Health metrics indicate higher risks. Consider reviewing options with a specialist.";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    // If user hasn't set up a displayName profile, fall back to email username cleanly
    final String fallbackName = currentUser?.displayName ??
        (currentUser?.email != null ? currentUser!.email!.split('@')[0] : "Developer");

    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Clean, modern off-white background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        automaticallyImplyLeading: false, // Cleaner view without implicit back buttons
        centerTitle: true,

        // Middle Logo Layout
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.monitor_weight_outlined, color: Colors.indigo.shade600, size: 24),
            const SizedBox(width: 8),
            const Text(
              "BMI CALCULATOR",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                fontSize: 16,
              ),
            ),
          ],
        ),

        // Right Side Account Actions
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                Text(
                  fallbackName,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
                  tooltip: "Sign Out",
                  onPressed: handleSignOut,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView( // Prevents UI overflow issues when phone keyboards pop up
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome Back 👋",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Track your health trends",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 32),

            // Modern Metric Input Card Panel
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    InputField(
                      controller: heightController,
                      label: "Height (cm)",
                    ),
                    const SizedBox(height: 18),
                    InputField(
                      controller: weightController,
                      label: "Weight (kg)",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Deep Indigo Main Action Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: calculateBMI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade600,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: Colors.indigo.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Calculate BMI",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Dynamic Status Panel (Fades into view once run)
            if (result.isNotEmpty)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: resultColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: resultColor.withOpacity(0.25), width: 1.5),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      "YOUR HEALTH SCORE",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: resultColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result,
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: resultColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Styled Category Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: resultColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tailored Health Insight
                    Text(
                      _getInsightMessage(category),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}