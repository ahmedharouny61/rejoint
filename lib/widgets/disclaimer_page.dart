// In disclaimer_page.dart or inline:
import 'package:flutter/material.dart';

class DisclaimerPage extends StatelessWidget {
  const DisclaimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff3e5f5),
      appBar: AppBar(
        title: const Text('Disclaimer'),titleTextStyle: TextStyle(fontSize: 30,color:const Color.fromARGB(255, 15, 0, 0) ,fontWeight: FontWeight.w500),
        backgroundColor:Color.fromARGB(255, 203, 199, 229),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
       
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text(
        'Medical Disclaimer',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 24),
      Text(
        'This app is intended for informational and educational purposes only. '
        'It is not a substitute for professional medical advice, diagnosis, or treatment.',
        style: TextStyle(
          fontSize: 18,
          height: 1.6, // Line spacing
        ),
        textAlign: TextAlign.justify,
      ),
      SizedBox(height: 16),
      Text(
        'Always seek the advice of your physician or other qualified health provider '
        'with any questions you may have regarding a medical condition.',
        style: TextStyle(
          fontSize: 18,
          height: 1.6,
        ),
        textAlign: TextAlign.justify,
      ),
      SizedBox(height: 24),
      Text(
        'By continuing to use the app, you agree to these terms.',
        style: TextStyle(
          fontSize: 18,
          fontStyle: FontStyle.italic,
          color: Color.fromARGB(255, 77, 71, 71),
        ),
        textAlign: TextAlign.center,
      ),
    ],
  ),
),

    );
  }
}
