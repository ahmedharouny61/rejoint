import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        // Implement user list UI
        return ListView.builder(
          itemCount: snapshot.data?.docs.length ?? 0,
          itemBuilder: (context, index) {
            final user = snapshot.data!.docs[index];
            return ListTile(
              title: Text(user['email']),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteUser(user.id),
              ),
            );
          },
        );
      },
    );
  }

Future<void> _deleteUser(String userId) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  final currentUserId = currentUser?.uid;

  if (currentUser == null) {
    throw FirebaseAuthException(
      code: 'not-authenticated',
      message: 'User is not signed in.',
    );
  }

  // Fetch current user's role from Firestore
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .get();

  if (userDoc.exists && userDoc.data()?['role'] == 'admin') {
    // 1. Delete Firestore user document
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();

    // 2. (Optional) Delete other related collections for the user here
    // Example: await FirebaseFirestore.instance.collection('user_data').doc(userId).delete();

    // 3. Delete user from Firebase Authentication
    try {
      // This requires you to use Admin SDK on a server or Cloud Function.
      // From client-side, you can't delete another user from Firebase Auth.
      print('Firestore document deleted. But user deletion from Auth requires Admin SDK.');
    } catch (e) {
      print('Error deleting user account: $e');
    }

    print('User $userId document deleted successfully from Firestore.');
  } else {
    throw FirebaseAuthException(
      code: 'permission-denied',
      message: 'You are not authorized to delete users.',
    );
  }
}

}