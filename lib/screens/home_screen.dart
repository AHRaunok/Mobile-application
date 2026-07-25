import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../theme_provider.dart';
import '../widgets/input_field.dart';
import 'login_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controllers
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final targetWeightController = TextEditingController();
  final calorieInputController = TextEditingController();
  final workoutDurationController = TextEditingController();
  final sleepInputController = TextEditingController();

  String result = "";
  String category = "";
  Color resultColor = Colors.indigo;

  double minIdealWeight = 0.0;
  double maxIdealWeight = 0.0;

  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Daily Health Tips Array
  final List<String> healthTips = [
    "💡 খাবার খাওয়ার অন্তত ৩০ মিনিট পর পানি পান করা হজমের জন্য সেরা।",
    "💡 প্রতিদিন ৭-৮ ঘণ্টা পর্যাপ্ত ঘুম ওজন নিয়ন্ত্রণে সাহায্য করে।",
    "💡 একটানা বসে না থেকে প্রতি ১ ঘণ্টায় ৫ মিনিট হাঁটার চেষ্টা করুন।",
    "💡 প্রক্রিয়াজাত খাবারের চেয়ে প্রাকৃতিক ও তাজা ফলমূল বেশি গ্রহণ করুন।",
    "💡 সকালের নাস্তা কখনো বাদ দেবেন না, এটি সারাদিনের এনার্জি যোগায়।",
    "💡 পর্যাপ্ত পানি পান করলে ত্বকের উজ্জ্বলতা ও কর্মক্ষমতা বৃদ্ধি পায়।",
    "💡 শরীরচর্চা ও নিয়মিত হাঁটা মানসিক চাপ কমাতে দারুণ কার্যকরী।",
  ];

  // Food Calorie Preset Database
  final List<Map<String, dynamic>> foodDatabase = [
    {"name": "ভাত (১ কাপ)", "calories": 200, "icon": Icons.rice_bowl},
    {"name": "রুটি (১ টি)", "calories": 100, "icon": Icons.bakery_dining},
    {"name": "ডিম সিদ্ধ (১ টি)", "calories": 75, "icon": Icons.egg},
    {"name": "মুরগির মাংস (১০০ গ্রাম)", "calories": 165, "icon": Icons.kebab_dining},
    {"name": "মাছ (১ টুকরো)", "calories": 150, "icon": Icons.set_meal},
    {"name": "ডাল (১ বাটি)", "calories": 120, "icon": Icons.soup_kitchen},
    {"name": "আপেল (১ টি)", "calories": 95, "icon": Icons.apple},
    {"name": "কলা (১ টি)", "calories": 105, "icon": Icons.lunch_dining},
    {"name": "দুধ (১ গ্লাস)", "calories": 150, "icon": Icons.local_cafe},
  ];

  // Workout Activities & Burn Rates
  final List<Map<String, dynamic>> workoutActivities = [
    {"name": "Running (রানিং)", "rate": 10.0, "icon": Icons.directions_run},
    {"name": "Cycling (সাইক্লিং)", "rate": 8.0, "icon": Icons.directions_bike},
    {"name": "Swimming (সাঁতার)", "rate": 9.0, "icon": Icons.pool},
    {"name": "Gym Workout (জিম)", "rate": 6.5, "icon": Icons.fitness_center},
    {"name": "Walking (হাঁটা)", "rate": 4.0, "icon": Icons.directions_walk},
  ];

  String selectedWorkout = "Running (রানিং)";

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    targetWeightController.dispose();
    calorieInputController.dispose();
    workoutDurationController.dispose();
    sleepInputController.dispose();
    super.dispose();
  }

  String _getTodayDate() {
    DateTime now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String _getTodayHealthTip() {
    int dayOfYear = DateTime.now().day;
    return healthTips[dayOfYear % healthTips.length];
  }

  void _saveTargetWeight() async {
    if (targetWeightController.text.isEmpty || currentUser == null) return;
    double? target = double.tryParse(targetWeightController.text);
    if (target == null || target <= 0) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .set({'targetWeight': target}, SetOptions(merge: true));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Target weight updated!")),
    );
    targetWeightController.clear();
  }

  void _updateWater(int amount) async {
    if (currentUser == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('daily_logs')
        .doc(_getTodayDate())
        .set({'waterIntake': FieldValue.increment(amount)}, SetOptions(merge: true));
  }

  void _addCaloriesDirectly(int calories) async {
    if (currentUser == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('daily_logs')
        .doc(_getTodayDate())
        .set({'calorieIntake': FieldValue.increment(calories)}, SetOptions(merge: true));
  }

  void _addCalories() {
    if (calorieInputController.text.isEmpty) return;
    int? calories = int.tryParse(calorieInputController.text);
    if (calories != null && calories > 0) {
      _addCaloriesDirectly(calories);
      calorieInputController.clear();
    }
  }

  // Sleep Tracker Update
  void _updateSleepDuration(double hours) async {
    if (currentUser == null || hours <= 0) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('daily_logs')
        .doc(_getTodayDate())
        .set({'sleepHours': hours}, SetOptions(merge: true));

    sleepInputController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("ঘুমের সময় $hours ঘণ্টা সেভ করা হয়েছে!")),
    );
  }

  // Record Workout & Burn Calories
  void _addWorkoutLog([int? customMinutes]) async {
    if (currentUser == null) return;
    int minutes = customMinutes ?? int.tryParse(workoutDurationController.text) ?? 0;
    if (minutes <= 0) return;

    var selectedActivity = workoutActivities.firstWhere((a) => a['name'] == selectedWorkout);
    double rate = selectedActivity['rate'] as double;
    int caloriesBurned = (minutes * rate).round();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('daily_logs')
        .doc(_getTodayDate())
        .set({'burnedCalories': FieldValue.increment(caloriesBurned)}, SetOptions(merge: true));

    workoutDurationController.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$caloriesBurned kcal বার্ন রেকর্ড করা হয়েছে!")),
    );
  }

  void _showFoodPickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("ফুড সিলেক্ট করুন (Food Database)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: foodDatabase.length,
                  itemBuilder: (context, index) {
                    var food = foodDatabase[index];
                    return ListTile(
                      leading: Icon(food['icon'] as IconData, color: Colors.indigo),
                      title: Text(food['name']),
                      trailing: Text("+${food['calories']} kcal", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                      onTap: () {
                        _addCaloriesDirectly(food['calories'] as int);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${food['name']} যোগ করা হয়েছে!")),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void calculateBMI() async {
    if (heightController.text.isEmpty || weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in both fields first!")),
      );
      return;
    }

    double? height = double.tryParse(heightController.text);
    double? weight = double.tryParse(weightController.text);

    if (height == null || weight == null || height <= 0 || weight <= 0) return;

    double heightInMeters = height / 100;
    double bmi = weight / (heightInMeters * heightInMeters);

    double minWeight = 18.5 * (heightInMeters * heightInMeters);
    double maxWeight = 24.9 * (heightInMeters * heightInMeters);

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
      minIdealWeight = minWeight;
      maxIdealWeight = maxWeight;
    });

    if (currentUser != null) {
      await FirebaseFirestore.instance.collection('bmi_history').add({
        'userId': currentUser!.uid,
        'bmi': double.parse(bmi.toStringAsFixed(1)),
        'category': cat,
        'height': height,
        'weight': weight,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  void handleSignOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("BMI & HEALTH CARE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () => themeProvider.toggleTheme(!themeProvider.isDarkMode),
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.indigo),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen())),
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).snapshots(),
            builder: (context, snapshot) {
              String name = currentUser?.displayName ?? currentUser?.email?.split('@')[0] ?? "User";
              if (snapshot.hasData && snapshot.data!.exists) {
                var data = snapshot.data!.data() as Map<String, dynamic>;
                if (data['name'] != null && data['name'].toString().isNotEmpty) {
                  name = data['name'];
                }
              }
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                child: Text(
                  name,
                  style: TextStyle(color: Colors.indigo.shade400, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
            onPressed: handleSignOut,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Streak Counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Welcome Back 👋", style: TextStyle(fontSize: 13, color: Colors.grey)),
                    SizedBox(height: 2),
                    Text("Track your health trends", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),

                // FEATURE 2: Streak Counter Badge
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser!.uid)
                      .collection('daily_logs')
                      .snapshots(),
                  builder: (context, snapshot) {
                    int streakCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        children: [
                          const Text("🔥 ", style: TextStyle(fontSize: 14)),
                          Text("$streakCount Days", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange.shade900)),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // FEATURE 1: Daily Health Tip Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.indigo.shade500, Colors.indigo.shade800]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getTodayHealthTip(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13, height: 1.4),
              ),
            ),
            const SizedBox(height: 16),

            // FEATURE 6: Quick 1-Click Action Chips
            const Text("⚡ Quick Actions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.local_drink, color: Colors.blue, size: 16),
                    label: const Text("+1 Glass Water"),
                    onPressed: () => _updateWater(1),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.fastfood, color: Colors.orange, size: 16),
                    label: const Text("+200 kcal Snack"),
                    onPressed: () => _addCaloriesDirectly(200),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.directions_walk, color: Colors.green, size: 16),
                    label: const Text("+15 Min Walk"),
                    onPressed: () {
                      selectedWorkout = "Walking (হাঁটা)";
                      _addWorkoutLog(15);
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.bed, color: Colors.purple, size: 16),
                    label: const Text("Set 8h Sleep"),
                    onPressed: () => _updateSleepDuration(8.0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Target Weight Card
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).snapshots(),
              builder: (context, snapshot) {
                double targetWeight = 0.0;
                if (snapshot.hasData && snapshot.data!.exists) {
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  targetWeight = (data['targetWeight'] as num?)?.toDouble() ?? 0.0;
                }
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Target Weight: ${targetWeight > 0 ? "$targetWeight kg" : "Not Set"}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Text("Set your fitness goal", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: TextField(
                            controller: targetWeightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: "kg", isDense: true),
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.check_circle, color: Colors.indigo), onPressed: _saveTargetWeight),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Daily Progress Rings & Sleep Log
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser!.uid)
                  .collection('daily_logs')
                  .doc(_getTodayDate())
                  .snapshots(),
              builder: (context, snapshot) {
                int waterIntake = 0;
                int calorieIntake = 0;
                double sleepHours = 0.0;

                if (snapshot.hasData && snapshot.data!.exists) {
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  waterIntake = (data['waterIntake'] as num?)?.toInt() ?? 0;
                  calorieIntake = (data['calorieIntake'] as num?)?.toInt() ?? 0;
                  sleepHours = (data['sleepHours'] as num?)?.toDouble() ?? 0.0;
                  if (waterIntake < 0) waterIntake = 0;
                }

                double waterProgress = (waterIntake / 8).clamp(0.0, 1.0);
                double calorieProgress = (calorieIntake / 2000).clamp(0.0, 1.0);

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Today's Progress Rings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.indigo)),
                            IconButton(
                              icon: const Icon(Icons.restaurant_menu, color: Colors.orange),
                              tooltip: "Search Food Calorie",
                              onPressed: _showFoodPickerModal,
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Water Circular Ring
                            Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 65,
                                      height: 65,
                                      child: CircularProgressIndicator(
                                        value: waterProgress,
                                        strokeWidth: 6,
                                        backgroundColor: Colors.blue.shade50,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Text("$waterIntake/8", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text("Water (Glasses)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                                Row(
                                  children: [
                                    IconButton(icon: const Icon(Icons.remove, color: Colors.redAccent, size: 20), onPressed: () => _updateWater(-1)),
                                    IconButton(icon: const Icon(Icons.add, color: Colors.blue, size: 20), onPressed: () => _updateWater(1)),
                                  ],
                                )
                              ],
                            ),

                            // Calorie Circular Ring
                            Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 65,
                                      height: 65,
                                      child: CircularProgressIndicator(
                                        value: calorieProgress,
                                        strokeWidth: 6,
                                        backgroundColor: Colors.orange.shade50,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    Text("$calorieIntake", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text("Calories (kcal)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                                SizedBox(
                                  width: 80,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: calorieInputController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(hintText: "kcal", isDense: true),
                                        ),
                                      ),
                                      IconButton(icon: const Icon(Icons.add_box, color: Colors.orange, size: 20), onPressed: _addCalories),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        const Divider(height: 24),

                        // FEATURE 3: Sleep Tracker Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.bedtime_rounded, color: Colors.purple, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "Sleep Tracker: ${sleepHours > 0 ? "$sleepHours hrs" : "Not Logged"}",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 65,
                              child: TextField(
                                controller: sleepInputController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(hintText: "hrs", isDense: true),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.save, color: Colors.purple),
                              onPressed: () {
                                double? hrs = double.tryParse(sleepInputController.text);
                                if (hrs != null) _updateSleepDuration(hrs);
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // BMI Input Panel
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    InputField(controller: heightController, label: "Height (cm)"),
                    const SizedBox(height: 14),
                    InputField(controller: weightController, label: "Weight (kg)"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Calculate Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: calculateBMI,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Calculate BMI", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),

            // BMI Results Panel
            if (result.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: resultColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: resultColor)),
                child: Column(
                  children: [
                    Text("BMI SCORE: $result", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: resultColor)),
                    const SizedBox(height: 4),
                    Text(category.toUpperCase(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: resultColor)),
                    const Divider(height: 18),
                    Text("Ideal Weight Range: ${minIdealWeight.toStringAsFixed(1)} kg - ${maxIdealWeight.toStringAsFixed(1)} kg", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // WORKOUT & EXERCISE TRACKER
            const Text("🏋️ Workout & Activity Tracker", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 10),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedWorkout,
                      decoration: InputDecoration(
                        labelText: "Select Activity",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: workoutActivities.map((act) {
                        return DropdownMenuItem<String>(
                          value: act['name'] as String,
                          child: Row(
                            children: [
                              Icon(act['icon'] as IconData, color: Colors.indigo, size: 18),
                              const SizedBox(width: 8),
                              Text(act['name'] as String, style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedWorkout = val!),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: workoutDurationController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Duration (Minutes)",
                              hintText: "e.g. 30",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _addWorkoutLog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Log Burned", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Today's Calorie Balance Dashboard
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser!.uid)
                  .collection('daily_logs')
                  .doc(_getTodayDate())
                  .snapshots(),
              builder: (context, snapshot) {
                int burned = 0;
                int intake = 0;

                if (snapshot.hasData && snapshot.data!.exists) {
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  burned = (data['burnedCalories'] as num?)?.toInt() ?? 0;
                  intake = (data['calorieIntake'] as num?)?.toInt() ?? 0;
                }

                int netCalories = intake - burned;

                return Card(
                  color: Colors.indigo.shade50.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.indigo.shade200)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text("🔥 Today's Calorie Balance", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.indigo)),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text("Intake", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text("$intake kcal", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orange)),
                              ],
                            ),
                            const Text("-", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Column(
                              children: [
                                const Text("Burned", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text("$burned kcal", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.redAccent)),
                              ],
                            ),
                            const Text("=", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Column(
                              children: [
                                const Text("Net Total", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text(
                                  "$netCalories kcal",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: netCalories <= 2000 ? Colors.green.shade700 : Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}