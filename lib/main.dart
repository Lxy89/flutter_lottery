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
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    runApp(MaterialApp(
      home: LoginScreen(),
       routes: {
      '/login': (context) => LoginScreen(),
    },
    ));
  } catch (e) {
    print("Firebase initialization error: $e");
  }
}