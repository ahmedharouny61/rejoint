import 'package:flutter/material.dart';
import 'package:graduation_project2/widgets/auth_page.dart';
import 'package:graduation_project2/widgets/disclaimer_page.dart';

class DisclaimerGate extends StatefulWidget {
  const DisclaimerGate({super.key});

  @override
  State<DisclaimerGate> createState() => _DisclaimerGateState();
}

class _DisclaimerGateState extends State<DisclaimerGate> {
  bool _agreed = false;

  @override
  void initState() {
    super.initState();
    // You could use SharedPreferences here to persist agreement
  }

  @override
  Widget build(BuildContext context) {
    return _agreed
        ? const AuthPage()
        : Scaffold(
            body: DisclaimerPage(),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                setState(() => _agreed = true);
              },
              label: const Text('I Agree'),
              icon: const Icon(Icons.check),
              backgroundColor: Color(0xfff3e5f5),
            ),
          );
  }
}
