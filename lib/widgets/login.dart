import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';


import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduation_project2/services/user_service.dart';
import 'package:graduation_project2/widgets/signup.dart';


class Login extends StatefulWidget {
  
const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                TextField(
                  controller: emailController,
                  style: const TextStyle(color:   Color.fromARGB(255, 236, 119, 245)), // White text
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                      labelText: 'email',
                      labelStyle: TextStyle(color: const Color.fromARGB(255, 243, 233, 233))),
                ),
                SizedBox(height: 4),
                TextField(
                  controller: passwordController,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(color:   Color.fromARGB(255, 236, 119, 245)), // pink text
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'password',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: signin,
                  icon: Icon(Icons.lock_open),
                  label: Text('Sign In'),
                ),
                SizedBox(
                  height: 24,
                ),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    text: 'No account',
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
 Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Signup()),
      );
                          },
                        text: 'Sign Up',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color:  const Color.fromARGB(255, 236, 119, 245)
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signin() async {
  if (emailController.text.isEmpty || passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please enter email and password")),
    );
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
     await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
  Navigator.of(context).pop(); // Remove loading dialog
  // Check if the user is admin
    final isAdmin = await UserService.isAdmin();

  

  

    if (isAdmin) {
      Navigator.pushNamedAndRemoveUntil(context, '/admin', (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Login successful")),
    );
  } on FirebaseAuthException catch (e) {
    Navigator.of(context).pop(); // Dismiss loading indicator

    String message = "An error occurred";

    if (e.code == 'user-not-found') {
      message = "No user found for this email.";
    } else if (e.code == 'wrong-password') {
      message = "Incorrect password. Try again.";
    } else if (e.code == 'invalid-email') {
      message = "Invalid email format.";
    } else {
      message = e.message ?? "Login failed.";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

}