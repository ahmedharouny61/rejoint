import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ImageProvider? _decodedImage;
  File? _profileImage;
  final User _user = FirebaseAuth.instance.currentUser!;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
String activeScreen = 'login'; // GLOBAL


 Future<void> _pickImage() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile == null) return;

  final imageBytes = await pickedFile.readAsBytes();
  final base64Image = base64Encode(imageBytes);

  // Update Firestore
  await FirebaseFirestore.instance.collection('users').doc(_user.uid).update({
    'profileImageBase64': base64Image,
  });

  // Save in SharedPreferences using user-specific key
  final prefs = await SharedPreferences.getInstance();
  final userId = _user.uid;
  await prefs.setString('cachedProfileImage_$userId', base64Image); // ✅ Fixed

  // Update UI
  setState(() {
    _decodedImage = MemoryImage(imageBytes);
    _profileImage = null; // clear old FileImage reference
  });
}

Future<void> _loadImage() async {
  final prefs = await SharedPreferences.getInstance();

  final userId = _user.uid;
  final localKey = 'cachedProfileImage_$userId';

  // Load from local cache first
  final cachedBase64 = prefs.getString(localKey);
  if (cachedBase64 != null) {
    final cachedBytes = base64Decode(cachedBase64);
    setState(() {
      _decodedImage = MemoryImage(cachedBytes);
      _profileImage = null;
    });
  }

  // Fetch latest from Firestore
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get();

  usernameController.text = doc.data()?['username'] ?? '';

  final firestoreBase64 = doc.data()?['profileImageBase64'];
  if (firestoreBase64 != null && firestoreBase64 != cachedBase64) {
    final firestoreBytes = base64Decode(firestoreBase64);

    // Update local cache
    await prefs.setString(localKey, firestoreBase64);

    setState(() {
      _decodedImage = MemoryImage(firestoreBytes);
      _profileImage = null;
    });
  }
}




  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _updateUsername() async {
    final newUsername = usernameController.text.trim();
    if (newUsername.isEmpty) {
      _showSnackBar("Username can't be empty.");
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .update({'username': newUsername});

    await _user.updateDisplayName(newUsername);

    _showSnackBar("Username updated successfully.");
  }

  Future<void> _changePassword() async {
    final newPassword = passwordController.text.trim();
    if (newPassword.length < 6) {
      _showSnackBar("Password must be at least 6 characters.");
      return;
    }

    try {
      await _user.updatePassword(newPassword);
      _showSnackBar("Password updated successfully.");
      passwordController.clear();
    } catch (e) {
      _showSnackBar("Failed to update password: ${e.toString()}");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff3e5f5),
      appBar: AppBar(backgroundColor: Color.fromARGB(255, 203, 199, 229),
        title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : _decodedImage,
                  child: (_profileImage == null && _decodedImage == null)
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _user.email ?? 'No email provided',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Username Update
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Change Username'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(),
                onPressed: _updateUsername,
                child: const Text('Update Username'),
              ),

              const SizedBox(height: 24),

              // Password Update
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    // backgroundColor:Colors.blue,
                    ),
                onPressed: _changePassword,
                child: const Text('Change Password'),
              ),

              const SizedBox(height: 40),
             ElevatedButton(
  onPressed: () async {
    await FirebaseAuth.instance.signOut();
    activeScreen = 'login'; // Reset screen state
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  },
  child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
