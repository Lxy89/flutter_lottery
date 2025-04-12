import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_lottery/screen/qr_code.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;

  const CartScreen({super.key, required this.cart});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<Map<String, dynamic>> _cart;

  @override
  void initState() {
    super.initState();
    _cart = List.from(widget.cart);
  }

  void _removeItem(int index) async {
    var item = _cart[index];
    String docId = item['lottery_id'];

    await FirebaseFirestore.instance
        .collection('lotteries')
        .doc(docId)
        .update({'available': true});

    setState(() {
      _cart.removeAt(index);
    });

    print("✅ คืนลอตเตอรี่ $docId กลับมาให้ซื้อได้อีกครั้ง");
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = _cart.fold(0, (sum, item) => sum + item['price']);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _cart); // ส่งกลับ cart ที่อัปเดต
        return false; // กันไม่ให้ pop ซ้ำ
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("ตะกร้าของคุณ"),
        ),
        body: _cart.isEmpty
            ? Center(child: Text("ตะกร้าของคุณว่าง"))
            : ListView.builder(
                itemCount: _cart.length,
                itemBuilder: (context, index) {
                  var item = _cart[index];
                  return ListTile(
                    title: Text("เลข ${item['number']}"),
                    subtitle: Text("ราคา: ${item['price']} บาท"),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeItem(index),
                    ),
                  );
                },
              ),
        bottomNavigationBar: _cart.isEmpty
            ? null
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PromptPayPage(
                          totalPrice: totalPrice,
                          cart: _cart,
                          userEmail:
                              FirebaseAuth.instance.currentUser?.email ?? '',
                        ),
                      ),
                    );

                    if (result == true) {
                      setState(() {
                        _cart.clear(); // เคลียร์ตะกร้าท้องถิ่น
                      });
                      Navigator.pop(context, []); // ส่งกลับตะกร้าว่าง
                    }
                  },
                  child: Text(
                    "ไปที่การชำระเงิน  รวม: $totalPrice บาท",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
      ),
    );
  }
}
