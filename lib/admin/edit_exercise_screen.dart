import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditExerciseScreen extends StatefulWidget {
  final DocumentSnapshot exerciseDoc;

  const EditExerciseScreen({super.key, required this.exerciseDoc});

  @override
  State<EditExerciseScreen> createState() => _EditExerciseScreenState();
}

class _EditExerciseScreenState extends State<EditExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  late TextEditingController _targetController;
  late TextEditingController _purposeController;

  @override
  void initState() {
    super.initState();
    final data = widget.exerciseDoc.data() as Map<String, dynamic>;
    _nameController = TextEditingController(text: data['name']);
    _urlController = TextEditingController(text: data['videoUrl']);
    _targetController = TextEditingController(text: data['target']);
    _purposeController = TextEditingController(text: data['purpose']);
  }

  Future<void> _updateExercise() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseFirestore.instance
          .collection('exercises')
          .doc(widget.exerciseDoc.id)
          .update({
            'name': _nameController.text,
            'videoUrl': _urlController.text,
            'target': _targetController.text,
            'purpose': _purposeController.text,
          });
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating exercise: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Exercise')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Exercise Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              // Add similar fields for URL, Target, Purpose
              ElevatedButton(
                onPressed: _updateExercise,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}