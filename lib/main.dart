import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduation_project2/admin/admin_wrapper.dart';
import 'package:graduation_project2/firebase_options.dart';
import 'package:graduation_project2/widgets/auth_page.dart';

import 'package:graduation_project2/widgets/disclaimer_gate.dart';
import 'package:graduation_project2/widgets/disclaimer_page.dart';
import 'package:graduation_project2/widgets/exercise_home_screen.dart';
import 'package:graduation_project2/widgets/home_screen.dart';
import 'package:graduation_project2/widgets/knee_survey_page.dart';
import 'package:graduation_project2/widgets/login.dart';
import 'package:graduation_project2/widgets/notification_helper.dart';
import 'package:graduation_project2/widgets/profile_screen.dart';
import 'package:graduation_project2/widgets/signup.dart';
import 'package:graduation_project2/widgets/video_player_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationHelper();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    MyApp(),
  );
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const DisclaimerGate(),
        '/video': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return VideoPlayerPage(
            videoUrl: args['videoUrl']!,
            exerciseName: args['exerciseName']!,
          );
        },
        '/auth': (context) => const AuthPage(), // New route for after agreement
        '/admin': (context) => const AdminWrapper(),
        '/home': (context) => const MainWrapper(),
        '/survey': (context) => const KneeSurveyPage(),
        '/signup': (context) => Signup(),
        '/login': (context) => Login(),
        '/disclaimer': (context) => const DisclaimerPage(),
      },
    );
  }
}

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _userPages = const [
    HomeScreen(),
    ExerciseHomeScreen(),
    ProfileScreen(),
  ];
  @override
  void initState() {
    super.initState();
    NotificationHelper.scheduleDailyNotification(
      'Reminder',
      'Time to do your knee exercises!',
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _userPages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Color.fromARGB(255, 203, 199, 229),
        selectedItemColor: Color(0xFF4169E1),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Exercises',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
