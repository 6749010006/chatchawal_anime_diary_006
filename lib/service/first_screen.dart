//จัดทำโดยชัชวาลย์ เมฆารักษ์กุล   รหัสนศ.6749010006

import 'package:flutter/material.dart'; //flutter/material.dart สำหรับ Widget UI ของ Flutter
import 'package:flutter_spinkit/flutter_spinkit.dart'; //flutter_spinkit สำหรับแสดง Loading Spinner สวย ๆ
import 'dart:async'; //dart:async สำหรับใช้ Timer
import 'package:chatchawal_anime_diary_006/pages/home.dart'; // หน้า Home ของคุณ

//FirstScreen Stateful Widget
class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  //initState
  @override
  void initState() {
    super.initState();
    // กำหนดเวลา 15 วินาที แล้วไปหน้า Home
    Timer(const Duration(seconds: 15), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
      );
    });
  }

  //Build UI
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    //ดึงขนาดหน้าจอเพื่อให้ background image เต็มจอ
    return Scaffold(
      body: Stack(
        children: [
          // Background image Background เป็นรูป First4.png
          //ใช้ BoxFit.fill ให้เต็มหน้าจอพอดี
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
                  //กล่องโลโก้โปร่งแสง (opacity 0.8) มีเงาและขอบโค้ง แสดงรูปโลโก้ LOgoLO.png ขนาดสูง 150
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
                //SizedBox เว้นระยะระหว่างโลโก้กับ spinner SpinKitPumpingHeart เป็น animation หัวใจเต้น สีชมพู ขนาด 50
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
