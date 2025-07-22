import 'package:flutter/material.dart';
import 'package:graduation_project2/widgets/gradiant_container.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int dayStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString('lastExerciseDate');
    final streak = prefs.getInt('dayStreak') ?? 0;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastDateStr == null || lastDateStr != today) {
      // It's a new day!
      await prefs.setInt('dayStreak', streak + 1);
      await prefs.setString('lastExerciseDate', today);
      setState(() {
        dayStreak = streak + 1;
      });
    } else {
      // Already counted today
      setState(() {
        dayStreak = streak;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradiantContainer(
        cooler: const [
          Color(0xFF1B1B3A),
          Color(0xFF4B0082),
          Color(0xFF6A5ACD),
          Color(0xFF4169E1),
        ],
        widget: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 40),

                // 🔥 Streak Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🔥',
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$dayStreak-day streak!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Your recommendation card (same as before)
                SizedBox(
                  width: 320,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset(
                            'assets/animations/Lunge.json',
                            width: 250,
                            height: 250,
                            repeat: true,
                            animate: true,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Today's Recommended Move",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Gentle on the knees, powerful for your strength.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/survey'),
                            child: RichText(
                              text: TextSpan(
                                text: 'start',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 13, 13, 13),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 35,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
