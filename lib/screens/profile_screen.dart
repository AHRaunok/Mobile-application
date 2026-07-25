import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  String selectedGender = "Male";
  String activityLevel = "Sedentary"; // Sedentary, Light, Moderate, Active

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    if (currentUser == null) return;
    var doc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
    if (doc.exists) {
      var data = doc.data()!;
      setState(() {
        nameController.text = data['name'] ?? currentUser?.displayName ?? "";
        ageController.text = (data['age'] ?? "").toString();
        selectedGender = data['gender'] ?? "Male";
        activityLevel = data['activityLevel'] ?? "Sedentary";
      });
    }
  }

  void _saveProfile() async {
    if (currentUser == null) return;
    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).set({
        'name': nameController.text.trim(),
        'age': int.tryParse(ageController.text) ?? 25,
        'gender': selectedGender,
        'activityLevel': activityLevel,
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("User Profile & BMR Goal", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Avatar Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.indigo.shade100,
                    child: Icon(Icons.person, size: 50, color: Colors.indigo.shade700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentUser?.email ?? "",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const Text("Personal Info", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 12),

            // Name Input
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Age Input
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Age (Years)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Gender Selection
            DropdownButtonFormField<String>(
              value: selectedGender,
              decoration: InputDecoration(
                labelText: "Gender",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: ["Male", "Female"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (val) => setState(() => selectedGender = val!),
            ),
            const SizedBox(height: 16),

            // Activity Level
            DropdownButtonFormField<String>(
              value: activityLevel,
              decoration: InputDecoration(
                labelText: "Daily Activity Level",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: "Sedentary", child: Text("Sedentary (Little or no exercise)")),
                DropdownMenuItem(value: "Light", child: Text("Lightly Active (1-3 days/week)")),
                DropdownMenuItem(value: "Moderate", child: Text("Moderately Active (3-5 days/week)")),
                DropdownMenuItem(value: "Active", child: Text("Very Active (6-7 days/week)")),
              ],
              onChanged: (val) => setState(() => activityLevel = val!),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}