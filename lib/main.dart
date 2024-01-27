import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/colors.dart';
import 'package:intl/intl.dart';
import 'screens/profilepage.dart';
import 'task_model.dart';
import 'screens/sign_up.dart';
import 'task_provider.dart';
import 'task_card.dart';
import 'kanbanboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF92A4CF)),
          useMaterial3: true,
          scaffoldBackgroundColor: Color.fromARGB(255, 253, 253, 253),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 218, 212, 212)),
            ),
          ),
        ),
        home: const MyHomePage(title: 'Flow Muse Sign In'),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TextEditingController _nameController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  Future<void> _submitForm() async {
    final String name = _nameController.text;
    final String password = _passwordController.text;

    if (name.isNotEmpty && password.isNotEmpty) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: name,
          password: password,
        );

        // Successfully signed in
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => KanbanBoard()),
        );
      } catch (e) {
        // Handle sign-in errors (e.g., user not found, wrong password)
        print('Error signing in: $e');
      }
    }
  }

  Future<void> _createAccount() async {
    final String name = _nameController.text;
    final String password = _passwordController.text;

    if (name.isNotEmpty && password.isNotEmpty) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: name,
          password: password,
        );

        // Successfully created account
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => KanbanBoard()),
        );
      } catch (e) {
        // Handle account creation errors (e.g., email already exists)
        print('Error creating account: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 30),
            const Text(
              'Flow Muse',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold,),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 15), // Adjust the left padding as needed
                    child: Text(
                      'Email',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _submitForm(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 15), // Adjust the left padding as needed
                    child: Text(
                      'Password',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        border: InputBorder.none,
                      ),
                      obscureText: true,
                      onSubmitted: (_) => _submitForm(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30,),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: stylePink,
                foregroundColor: Colors.black,
              ),
              child: const Text('Log In'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateProfilePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: stylePink,
                foregroundColor: Colors.black,
              ),
              child: const Text('Create Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
