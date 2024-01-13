import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: appBackBlue,
      ),
      backgroundColor: appBackBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
            ),
            const SizedBox(height: 20),
            const Text(
              'Username',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                  // Will add delete functionality later
              },
              style: ElevatedButton.styleFrom(primary: Colors.red),
              child: const Text('Delete Account', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
