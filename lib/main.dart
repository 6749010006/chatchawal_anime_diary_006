//จัดทำโดยชัชวาลย์ เมฆารักษ์กุล   รหัสนศ.6749010006

import 'package:flutter/material.dart'; //นำเข้า Flutter Material สำหรับ Widget UI
import 'package:firebase_core/firebase_core.dart'; //นำเข้า Firebase Core สำหรับเชื่อม Firebase
import 'package:chatchawal_anime_diary_006/pages/home.dart'; //นำเข้า Home page และ FirstScreen ของแอพ
import 'package:chatchawal_anime_diary_006/service/first_screen.dart';
import 'firebase_options.dart'; //นำเข้าไฟล์ firebase_options.dart ซึ่งกำหนดค่า Firebase ของโปรเจกต์

//ฟังก์ชัน main
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

//MyApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const FirstScreen(),
    );
  }
}

//MyHomePage
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

//_MyHomePageState
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  //Build UI ของ MyHomePage
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
