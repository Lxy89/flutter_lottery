// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class CartService {
//   // ฟังก์ชันบันทึกข้อมูลตะกร้า
//   Future<void> saveCart(List<Map<String, dynamic>> cart) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String> cartStringList = cart.map((item) => json.encode(item)).toList();
//     await prefs.setStringList('cart', cartStringList);
//   }

//   // ฟังก์ชันโหลดข้อมูลตะกร้าจาก SharedPreferences
//   Future<List<Map<String, dynamic>>> loadCart() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String>? cartStringList = prefs.getStringList('cart');
    
//     if (cartStringList == null) {
//       return [];
//     }

//     List<Map<String, dynamic>> cart = cartStringList
//         .map((cartItem) => Map<String, dynamic>.from(json.decode(cartItem)))
//         .toList();

//     return cart;
//   }

//   Future<void> clearCart() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   await prefs.remove('cart');
// }

// }
