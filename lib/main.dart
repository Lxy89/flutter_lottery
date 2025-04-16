import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lottery/screen/login_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(); // เพิ่มบรรทัดนี้
//   runApp(MaterialApp(
//     home: LoginScreen()
//   ));
// }

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //  ทำให้แน่ใจว่า Flutter ถูก initialize ก่อนใช้ Firebase
  try {
    await Firebase.initializeApp();//  เรียกใช้ Firebase ก่อนเริ่มแอป
    runApp(MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 96, 48, 128),
          foregroundColor: Colors.white,
        ),
        
        primarySwatch: Colors.blue, // เปลี่ยนสีหลักของแอป
        scaffoldBackgroundColor: Colors.grey[200],
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 61, 139, 64),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
      },
    ));
  } catch (e) {
    print("Firebase initialization error: $e");
  }
}
