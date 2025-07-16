import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRoles {
  static const String admin = 'admin';
}

class UserService {
  static Future<void> setAdminRole(String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({'role': UserRoles.admin}, SetOptions(merge: true));
  }

  static Future<bool> isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
        
    return doc.data()?['role'] == UserRoles.admin;
  }

  // Add to user document on signup
  static Future<void> createUserDocument(User user) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
          'email': user.email,
          'role': 'user', // Default role
          'createdAt': FieldValue.serverTimestamp(),
        });
  }
}