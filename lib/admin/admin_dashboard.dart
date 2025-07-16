import 'package:flutter/material.dart';
import 'package:graduation_project2/admin/user_managment_screen.dart';
import 'package:graduation_project2/admin/video_management_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab( icon: Icon(Icons.people),), // Fixed syntax
              Tab(icon: Icon(Icons.video_library)),
            ],
          ),
        ),
        body: TabBarView(
          children: const [
            UserManagementScreen(),
            VideoManagementScreen(),
          ],
        ),
      ),
    );
  }
}