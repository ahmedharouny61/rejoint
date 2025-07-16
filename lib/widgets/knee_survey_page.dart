import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project2/widgets/exercise_home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class KneeSurveyPage extends StatefulWidget {
  const KneeSurveyPage({super.key});

  @override
  _KneeSurveyPageState createState() => _KneeSurveyPageState();
}

class _KneeSurveyPageState extends State<KneeSurveyPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final painLevelController = TextEditingController();
  final stiffnessLevelController = TextEditingController();
  final walkingDifficultyController = TextEditingController();
  final ageController = TextEditingController();
  final stiffnessDurationController = TextEditingController();
  final functionalScoreController = TextEditingController();

  // Dropdown values with default null values
  String? kneeSwelling;
  String? gender;
  String? walkingSeverity;
  String? assistiveDevice;
  String? xrayFindings;

  // Default values for dropdowns
  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> walkingSeverityOptions = ['Mild', 'Moderate', 'Severe'];
  final List<String> kneeSwellingOptions = ['Yes', 'No'];
  final List<String> assistiveDeviceOptions = ['None', 'Walker', 'Wheelchair'];
  final List<String> xrayFindingsOptions = [
    'Normal',
    'Mild Osteoarthritis',
    'Moderate Osteoarthritis',
    'Severe Osteoarthritis'
  ];

  @override
  void dispose() {
    // Clean up controllers
    painLevelController.dispose();
    stiffnessLevelController.dispose();
    walkingDifficultyController.dispose();
    ageController.dispose();
    stiffnessDurationController.dispose();
    functionalScoreController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) {
      _showErrorSnackbar('Authentication error. Please re-login.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http
          .post(
         Uri.parse("https://flask-ml-api-w48p.onrender.com/recommend"),

            headers: {"Content-Type": "application/json"},
            body: json.encode({
              'user_email': user!.email!,
              'Age': int.parse(ageController.text),
              'Pain_Level': int.parse(painLevelController.text),
              'Morning_Stiffness__min_':
                  int.parse(stiffnessDurationController.text),
              'Functional_Score': int.parse(functionalScoreController.text),
              'Gender': gender,
              'Difficulty_Walking': walkingSeverity,
              'Swelling': kneeSwelling,
              'Assistive_Device': assistiveDevice,
              'Xray_Findings': xrayFindings,
            }),
          )
          .timeout(const Duration(seconds: 30));

      Navigator.of(context).pop();

      final responseData = json.decode(response.body);

      if (response.statusCode != 200) {
        throw HttpException("Server responded with ${response.statusCode}");
      }

      final exerciseName =
          responseData['exercise_name']?.toString() ?? 'Unknown Exercise';
      final videoUrl = _getExerciseVideo(exerciseName);

      if (!videoUrl.startsWith('http')) {
        throw FormatException("Invalid video URL format");
      }

     Navigator.pushNamed(
    context,
    '/video',
    arguments: {
      'videoUrl': _getExerciseVideo(exerciseName),
      'exerciseName': exerciseName,
    },
  );
    } on SocketException {
      _showErrorSnackbar("No internet connection");
    } on TimeoutException {
      _showErrorSnackbar("Request timed out");
    } catch (e) {
      _showErrorSnackbar("Error: ${e.toString()}");
    }
  }

  Widget buildNumberInput(
    String label,
    TextEditingController controller,
    int min,
    int max, {
    required Color borderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor, width: 2.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor, width: 2.0),
            ),
            hintText: 'Enter value between $min-$max',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildDropdown(
    String label,
    String? value,
    List<String> options,
    Function(String?) onChanged, {
    required Color borderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor, width: 2.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor, width: 2.0),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 248, 235, 1),
      appBar: AppBar(title: const Text('Knee Osteoarthritis Survey')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Color.fromRGBO(10, 35, 66, 1))),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDropdown(
                  "1. What is your gender?",
                  gender,
                  genderOptions,
                  (newValue) => setState(() => gender = newValue),
                  borderColor: Color(0xFF4682B4),
                ),
                buildDropdown(
                  "2. How severe is your difficulty walking?",
                  walkingSeverity,
                  walkingSeverityOptions,
                  (newValue) => setState(() => walkingSeverity = newValue),
                  borderColor: Color(0xFF4682B4),
                ),
                buildDropdown(
                  "3. Do you experience knee swelling?",
                  kneeSwelling,
                  kneeSwellingOptions,
                  (newValue) => setState(() => kneeSwelling = newValue),
                  borderColor: Color(0xFF4682B4),
                ),
                buildDropdown(
                  "4. Do you use an assistive device?",
                  assistiveDevice,
                  assistiveDeviceOptions,
                  (newValue) => setState(() => assistiveDevice = newValue),
                  borderColor: Color(0xFF4682B4),
                ),
                buildDropdown(
                  "5. What were your latest X-ray findings?",
                  xrayFindings,
                  xrayFindingsOptions,
                  (newValue) => setState(() => xrayFindings = newValue),
                  borderColor: Color(0xFF4682B4),
                ),
                buildNumberInput(
                  "6. Age (1-120)",
                  ageController,
                  1,
                  120,
                  borderColor: Color(0xFF4682B4),
                ),
                buildNumberInput(
                  "7. Pain Level (0-10)",
                  painLevelController,
                  0,
                  10,
                  borderColor: Color(0xFF4682B4),
                ),
                buildNumberInput(
                  "8. Morning Stiffness Duration (0-60 minutes)",
                  stiffnessDurationController,
                  0,
                  60,
                  borderColor: Color(0xFF4682B4),
                ),
                buildNumberInput(
                  "9. Functional Score (0-100)",
                  functionalScoreController,
                  0,
                  100,
                  borderColor: Color(0xFF4682B4),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      backgroundColor: Color.fromRGBO(135, 206, 250, 1),
                    ),
                    child: const Text(
                      'Submit Survey',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color.fromRGBO(10, 35, 66, 1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      // Use State's mounted property
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

String _getExerciseVideo(String exerciseName) {
    final videoMapping = ExerciseHomeScreen.exerciseVideos;
  return videoMapping[exerciseName] ??
      'https://youtu.be/JMsqY_UegbM'; // Default video
}


