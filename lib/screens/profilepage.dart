import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/colors.dart';
import 'package:test/main.dart';

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
              radius: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Username',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                _showDeleteConfirmationDialog(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text('Delete Account', style: TextStyle(fontSize: 16, color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Are you sure you want to delete your account?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteAccount(context); // Call the _deleteAccount method here
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text('Delete Account', style: TextStyle(fontSize: 16, color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      // Delete the user account
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete();
      }

      // Sign out after deleting the account
      await FirebaseAuth.instance.signOut();

      // Close the delete confirmation dialog
      Navigator.pop(context);

      // Navigate to the new login page and clear the navigation stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage(title: 'Flow Muse Sign In')),
        (route) => false,
      );
    } catch (error) {
      print(error.toString());
      // Handle errors if needed
    }
  }
}
