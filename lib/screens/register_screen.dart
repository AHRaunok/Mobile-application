import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
final nameController = TextEditingController();
final emailController = TextEditingController();
final passwordController = TextEditingController();

final _formKey = GlobalKey<FormState>(); // Used to validate form inputs
bool _isLoading = false; // Tracks Firebase registration network status

Future<void> _registerUser() async {
// Exit early if form inputs are invalid
if (!_formKey.currentState!.validate()) return;

setState(() {
_isLoading = true;
});

try {
// 1. Create the user in Firebase Auth
final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
email: emailController.text.trim(),
password: passwordController.text.trim(),
);

// 2. Set their visual display name on their auth profile
await userCredential.user?.updateDisplayName(nameController.text.trim());

if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("Registration Successful! Welcome!"),
backgroundColor: Colors.green,
),
);
Navigator.pop(context); // Go back to the login screen
}
} on FirebaseAuthException catch (e) {
String errorMessage = "An error occurred. Please try again.";
if (e.code == 'weak-password') {
errorMessage = 'The password provided is too weak.';
} else if (e.code == 'email-already-in-use') {
errorMessage = 'The account already exists for that email.';
} else if (e.code == 'invalid-email') {
errorMessage = 'The email address is badly formatted.';
}

if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(errorMessage),
backgroundColor: Colors.redAccent,
),
);
}
} catch (e) {
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("Error: ${e.toString()}"),
backgroundColor: Colors.redAccent,
),
);
}
} finally {
if (mounted) {
setState(() {
_isLoading = false;
});
}
}
}

@override
void dispose() {
nameController.dispose();
emailController.dispose();
passwordController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Colors.grey[50], // Soft, clean background color
appBar: AppBar(
title: const Text(
"Create Account",
style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
),
backgroundColor: Colors.transparent,
elevation: 0,
leading: const BackButton(color: Colors.black87),
),
body: SafeArea(
child: SingleChildScrollView(
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
child: Form(
key: _formKey,
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
const SizedBox(height: 10),
Text(
"Join Us!",
style: Theme.of(context).textTheme.headlineMedium?.copyWith(
fontWeight: FontWeight.bold,
color: Colors.deepPurple,
),
),
const SizedBox(height: 8),
Text(
"Sign up to track your BMI and reach your health goals.",
style: TextStyle(color: Colors.grey[600], fontSize: 16),
),
const SizedBox(height: 35),

// Full Name Field
TextFormField(
controller: nameController,
decoration: InputDecoration(
labelText: "Full Name",
prefixIcon: const Icon(Icons.person_outline),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
),
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: BorderSide(color: Colors.grey[300]!),
),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
),
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return 'Please enter your name';
}
return null;
},
),
const SizedBox(height: 20),

// Email Field
// Email Field
  TextFormField(
    controller: emailController,
    keyboardType: TextInputType.emailAddress,
    decoration: InputDecoration(
      labelText: "Email Address",
      prefixIcon: const Icon(Icons.email_outlined),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.deepPurple,
          width: 2,
        ),
      ),
    ),
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Please enter your email';
      }
      if (!value.contains('@')) {
        return 'Please enter a valid email';
      }
      return null;
    },
  ),

  const SizedBox(height: 20),

// Password Field
  TextFormField(
    controller: passwordController,
    obscureText: true,
    decoration: InputDecoration(
      labelText: "Password",
      prefixIcon: const Icon(Icons.lock_outline),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.deepPurple,
          width: 2,
        ),
      ),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter a password';
      }
      if (value.length < 6) {
        return 'Password must be at least 6 characters';
      }
      return null;
    },
  ),

  const SizedBox(height: 30),

  SizedBox(
    height: 55,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _registerUser,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(
        color: Colors.white,
      )
          : const Text(
        "Create Account",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),

  const SizedBox(height: 20),

  TextButton(
    onPressed: () {
      Navigator.pop(context);
    },
    child: const Text(
      "Already have an account? Login",
      style: TextStyle(
        color: Colors.deepPurple,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
],
),
),
),
),
),
);
}
}
