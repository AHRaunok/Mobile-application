import 'package:flutter/material.dart';
import '../widgets/input_field.dart';

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
  Color resultColor = Colors.black;

  void calculateBMI() {
    double height = double.parse(heightController.text);
    double weight = double.parse(weightController.text);

    double bmi = weight / ((height / 100) * (height / 100));

    String cat;
    Color color;

    if (bmi < 18.5) {
      cat = "Underweight";
      color = Colors.blue;
    } else if (bmi < 25) {
      cat = "Normal";
      color = Colors.green;
    } else if (bmi < 30) {
      cat = "Overweight";
      color = Colors.orange;
    } else {
      cat = "Obese";
      color = Colors.red;
    }

    setState(() {
      result = bmi.toStringAsFixed(2);
      category = cat;
      resultColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BMI Calculator"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            InputField(
              controller: heightController,
              label: "Height (cm)",
            ),
            const SizedBox(height: 15),

            InputField(
              controller: weightController,
              label: "Weight (kg)",
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: calculateBMI,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Calculate BMI",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (result.isNotEmpty)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "Your BMI",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        result,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 22,
                          color: resultColor,
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
