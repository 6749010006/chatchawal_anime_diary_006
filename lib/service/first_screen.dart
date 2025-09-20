import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'package:chatchawal_anime_diary_006/pages/home.dart'; // หน้า Home ของคุณ

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  void initState() {
    super.initState();
    // กำหนดเวลา 3 วินาที แล้วไปหน้า Home
    Timer(const Duration(seconds: 15), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background image พอดีหน้าจอเป๊ะ
          SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: Image.asset('assets/images/First4.png', fit: BoxFit.fill),
          ),
          // โลโก้ตรงกลาง + spinner
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.asset('assets/images/LOgoLO.png', height: 150),
                ),
                const SizedBox(height: 30),
                const SpinKitPumpingHeart(color: Colors.pinkAccent, size: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
