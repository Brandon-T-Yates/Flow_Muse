import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/colors.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _moveController;
  late Animation<Offset> _moveAnimation;

  @override
  void initState() {
    super.initState();

    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _moveAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(0.0, -4.2),
    ).animate(_moveController);

    Timer(const Duration(seconds: 1), () {
      _moveController.forward().whenComplete(() {

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Flow Muse Sign In')),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackBlue,
      body: Center(
        child: SlideTransition(
          position: _moveAnimation,
          child: const Text(
            'Flow Muse',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _moveController.dispose();
    super.dispose();
  }
}