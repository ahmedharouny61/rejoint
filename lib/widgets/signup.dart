import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduation_project2/widgets/login.dart';

class Signup extends StatefulWidget {
 // In Signup

const Signup({super.key});


  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1B1B3A), // Dark Navy Blue (Darker shade)
              Color(0xFF4B0082), // Deep Purple (Adds contrast)
              Color(0xFF6A5ACD), // Slate Blue (Mid tone)
              Color(0xFF4169E1), // Royal Blue (Lighter tone for contrast)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                TextField(
                  controller: usernameController,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 236, 119, 245)),
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  style: const TextStyle(
                      color: Color.fromARGB(255, 236, 119, 245)),
                  controller: emailController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 12),
                TextField(
                  style: const TextStyle(
                      color: Color.fromARGB(255, 236, 119, 245)),
                  controller: passwordController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white)),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: signUp,
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Sign Up'),
                ),
                const SizedBox(height: 24),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    text: 'Already have an account? ',
                    children: [
                  TextSpan(
  recognizer: TapGestureRecognizer()
    ..onTap = () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    },
  text: ' Log in',
  style: TextStyle(
    decoration: TextDecoration.underline,
    color: Color.fromARGB(255, 236, 119, 245),
  ),
),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signUp() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showSnackBar("Please enter both email and password.");
      return;
    }

    showLoadingDialog();

    try {
      // 1. Create Firebase Auth user
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 2. Auto-create Firestore document
      if (userCredential.user != null) {
        await FirebaseFirestore.instance
    .collection('users')
    .doc(userCredential.user!.uid)
    .set({
      'email': userCredential.user!.email,
      'username': usernameController.text.trim(),
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });
      }

      // 3. Navigate to home
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      showSnackBar(e.message ?? "Sign-up failed.");
    } catch (e) {
      Navigator.of(context).pop();
      showSnackBar("Error creating profile: ${e.toString()}");
    }
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
