import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkTokenAndRole(); 
  }

  Future<void> _checkTokenAndRole() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); 
    final role = prefs.getString('rol');

    Future.delayed(const Duration(seconds: 2), () {
      if (token != null && token.isNotEmpty) {
        if (role == "TECHNICIAN") {
          Navigator.pushReplacementNamed(context, '/menuTechnician');
        } else if (role == "CLIENT") {
          Navigator.pushReplacementNamed(context, '/menuClient');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[100],
      body: Center(
        child: Image.asset(
          'assets/logo.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
