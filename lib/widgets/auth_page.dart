import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project2/widgets/login.dart';
import 'package:graduation_project2/widgets/signup.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String activeScreen = 'login';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Delay navigation until after build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/home');
          });
          return const SizedBox(); // empty widget while redirecting
        }

        return Scaffold(
          body: Center(
            child: activeScreen == 'login'
                ? Login()
                : Signup(),
          ),
        );
      },
    );
  }

  void toggleScreen() {
    setState(() {
      activeScreen = activeScreen == 'login' ? 'signup' : 'login';
    });
  }
}
