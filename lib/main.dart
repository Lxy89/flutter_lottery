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
    await Firebase.initializeApp();
    runApp(MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 96, 48, 128), // กำหนดสี AppBar ทุกหน้า
          foregroundColor: Colors.white, // กำหนดสีตัวหนังสือและไอคอน
        ),
        
        primarySwatch: Colors.blue, // เปลี่ยนสีหลักของแอป
        scaffoldBackgroundColor: Colors.grey[200], // เปลี่ยนสีพื้นหลัง
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black), // เปลี่ยนสีตัวอักษร
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 61, 139, 64), // สีพื้นหลังปุ่ม
            foregroundColor: Colors.white, // สีข้อความปุ่ม
          ),
        ),
      ),
      home: LoginScreen(), //  เรียกใช้ Firebase ก่อนเริ่มแอป
      routes: {
        '/login': (context) => LoginScreen(),
      },
    ));
  } catch (e) {
    print("Firebase initialization error: $e");
  }
}
