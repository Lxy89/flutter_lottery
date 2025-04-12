import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PromptPayPage extends StatelessWidget {
  final double totalPrice;
  final List<Map<String, dynamic>> cart;
  final String userEmail;

  const PromptPayPage({
    super.key,
    required this.totalPrice,
    required this.cart,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final promptPayNumber = ''; // ใส่เบอร์พร้อมเพย์จริง
    final qrData = 'promptpay://$promptPayNumber/${totalPrice.toStringAsFixed(2)}';

    return Scaffold(
      appBar: AppBar(title: Text('PromptPay QR')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(data: qrData, size: 200),
              Text("ยอดชำระทั้งหมด", style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),
              Text(
                "${totalPrice.toStringAsFixed(2)} บาท",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  // บันทึกการซื้อ
                  for (var item in cart) {
                    await FirebaseFirestore.instance.collection('purchases').add({
                      'lottery_id': item['lottery_id'],
                      'number': item['number'],
                      'price': item['price'],
                      'buyer': userEmail,
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                  }

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("✅ ชำระเงินสำเร็จ"),
                      content: Text("ขอบคุณที่ใช้บริการ"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // ปิด dialog
                            Navigator.pop(context, true); // ส่งสัญญาณเคลียร์ตะกร้า
                          },
                          child: Text("ปิด"),
                        ),
                      ],
                    ),
                  );
                },
                child: Text("ยืนยันการชำระเงิน", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
