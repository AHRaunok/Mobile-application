import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("ইউজার লগইন করা নেই।")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("History & Analytics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= 1. BMI HISTORY SECTION =================
            const Text(
              "📊 BMI History & Trend",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bmi_history')
                  .where('userId', isEqualTo: currentUser.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("এখনো কোনো BMI রেকর্ড সংরক্ষিত হয়নি।"),
                    ),
                  );
                }

                var docs = snapshot.data!.docs;

                return Column(
                  children: [
                    // BMI Visual Graph / Bar Chart
                    Container(
                      height: 150,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.indigo.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Recent BMI Graph", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo)),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: docs.length > 7 ? 7 : docs.length,
                              itemBuilder: (context, index) {
                                var item = docs[index].data() as Map<String, dynamic>;
                                double bmi = (item['bmi'] as num?)?.toDouble() ?? 0.0;
                                double barHeightRatio = ((bmi - 10) / 30).clamp(0.15, 1.0);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text("$bmi", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        width: 22,
                                        height: 80 * barHeightRatio,
                                        decoration: BoxDecoration(
                                          color: bmi < 18.5
                                              ? Colors.blue
                                              : (bmi < 25 ? Colors.green : (bmi < 30 ? Colors.orange : Colors.red)),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text("#${docs.length - index}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // BMI History Detailed List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        var data = docs[index].data() as Map<String, dynamic>;
                        double bmi = (data['bmi'] as num?)?.toDouble() ?? 0.0;
                        String category = data['category'] ?? "";
                        double weight = (data['weight'] as num?)?.toDouble() ?? 0.0;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo.shade100,
                              child: Text("${index + 1}", style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                            ),
                            title: Text("BMI: $bmi ($category)", style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Weight: $weight kg"),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),
            const Divider(thickness: 1.5),
            const SizedBox(height: 12),

            // ================= 2. WORKOUT & CALORIE HISTORY SECTION =================
            const Text(
              "🏋️ Workout & Calorie Burn History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('daily_logs')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("এখনো কোনো ডেইলি ওয়ার্কআউট বা ক্যালোরির হিস্ট্রি নেই।"),
                    ),
                  );
                }

                var logs = snapshot.data!.docs;

                return Column(
                  children: [
                    // Daily Burned Calories Bar Chart
                    Container(
                      height: 160,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Daily Calorie Burn Graph (kcal)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: logs.length,
                              itemBuilder: (context, index) {
                                var log = logs[index].data() as Map<String, dynamic>;
                                String dateId = logs[index].id; // e.g. 2026-07-26
                                int burned = (log['burnedCalories'] as num?)?.toInt() ?? 0;
                                double heightFactor = (burned / 1000).clamp(0.1, 1.0); // max 1000 kcal scale

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text("$burned", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                      const SizedBox(height: 4),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        width: 24,
                                        height: 85 * heightFactor,
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateId.length >= 5 ? dateId.substring(5) : dateId, // MM-DD format
                                        style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Detailed Daily Activity Log List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        var log = logs[index].data() as Map<String, dynamic>;
                        String date = logs[index].id;
                        int burned = (log['burnedCalories'] as num?)?.toInt() ?? 0;
                        int intake = (log['calorieIntake'] as num?)?.toInt() ?? 0;
                        int net = intake - burned;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      backgroundColor: Colors.redAccent,
                                      child: Icon(Icons.fitness_center, color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        const SizedBox(height: 2),
                                        Text("Burned: $burned kcal | Intake: $intake kcal", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: net <= 2000 ? Colors.green.shade50 : Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Net: $net",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: net <= 2000 ? Colors.green.shade800 : Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}