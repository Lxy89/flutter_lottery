// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class LotteryShoptest extends StatefulWidget {
//   const LotteryShoptest({super.key});

//   @override
//   _LotteryShopState createState() => _LotteryShopState();
// }

// class _LotteryShopState extends State<LotteryShoptest> {
//   final CollectionReference lotteryCollection =
//       FirebaseFirestore.instance.collection('lotteries');

//   // Cart to store selected items
//   List<Map<String, dynamic>> cart = [];

//   // Function to add items to the cart
//   void addToCart(String docId, String number, double price) {
//     setState(() {
//       cart.add({
//         'lottery_id': docId,
//         'number': number,
//         'price': price,
//       });
//     });
//   }

//   // Function to handle the purchase (add to purchases and update lottery availability)
//   Future<void> buyLottery(String docId, String number, double price) async {
//     // Add to cart first
//     addToCart(docId, number, price);

//     await lotteryCollection.doc(docId).update({'available': false});

//     // Record the purchase in Firestore
//     await FirebaseFirestore.instance.collection('purchases').add({
//       'lottery_id': docId,
//       'number': number,
//       'price': price,
//       'buyer': "user123", // Replace with actual user ID
//       'timestamp': FieldValue.serverTimestamp(),
//     });

//     // Show confirmation dialog
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("การซื้อสำเร็จ"),
//           content: Text("คุณได้ซื้อเลข $number ราคา $price บาท"),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close dialog
//               },
//               child: Text("ตกลง"),
//             ),
//           ],
//         );
//       },
//     );

//     print("✅ ซื้อสำเร็จ: $docId");
//   }

//   // Function to navigate to the cart screen
//   void viewCart() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => CartScreen(cart: cart),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('ร้านค้าลอตเตอรี่'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.shopping_cart),
//             onPressed: viewCart, // Navigate to cart screen
//           ),
//         ],
//       ),
//       body: StreamBuilder(
//         stream: lotteryCollection.snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text("ไม่มีลอตเตอรี่"));
//           }

//           var lotteries = snapshot.data!.docs;

//           return GridView.builder(
//             padding: const EdgeInsets.all(8),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 1.5,
//               crossAxisSpacing: 0,
//               mainAxisSpacing: 0,
//             ),
//             itemCount: lotteries.length,
//             itemBuilder: (context, index) {
//               var lotteryDoc = lotteries[index];
//               var lotteryData = lotteryDoc.data() as Map<String, dynamic>;
//               String lotteryId = lotteryDoc.id;

//               return Card(
//                 elevation: 3,
//                 child: Column(
//                   children: [
//                     ListTile(
//                       title: Text("เลข ${lotteryData['number']}"),
//                       subtitle: Text("ราคา: ${lotteryData['price']} บาท"),
//                     ),
//                     Spacer(),
//                     Padding(
//                       padding: const EdgeInsets.only(right: 4),
//                       child: Align(
//                         alignment: Alignment.bottomRight,
//                         child: ElevatedButton(
//                           onPressed: lotteryData['available']
//                               ? () => buyLottery(lotteryId,
//                                   lotteryData['number'], lotteryData['price'])
//                               : null,
//                           child:
//                               Text(lotteryData['available'] ? "ซื้อ" : "หมด"),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// // Cart screen to view selected items
// class CartScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> cart;

//   const CartScreen({super.key, required this.cart});

//   @override
//   Widget build(BuildContext context) {
//     double totalPrice = cart.fold(0, (sum, item) => sum + item['price']);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("ตะกร้าของคุณ"),
//       ),
//       body: cart.isEmpty
//           ? Center(child: Text("ตะกร้าของคุณว่าง"))
//           : ListView.builder(
//               itemCount: cart.length,
//               itemBuilder: (context, index) {
//                 var item = cart[index];
//                 return ListTile(
//                   title: Text("เลข ${item['number']}"),
//                   subtitle: Text("ราคา: ${item['price']} บาท"),
//                 );
//               },
//             ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: ElevatedButton(
//           onPressed: () {
//             // Implement checkout functionality
//           },
//           child: Text("ไปที่การชำระเงิน (รวม: $totalPrice บาท)"),
//         ),
//       ),
//     );
//   }
// }