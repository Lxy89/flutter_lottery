import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddLotteryPage extends StatefulWidget {
  const AddLotteryPage({super.key});

  @override
  _AddLotteryPageState createState() => _AddLotteryPageState();
}

class _AddLotteryPageState extends State<AddLotteryPage> {
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final CollectionReference lotteryCollection =
      FirebaseFirestore.instance.collection('lotteries');

  Future<void> addLottery() async {
    String number = _numberController.text.trim();
    double price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    if (number.isEmpty || price <= 0) {
      // แสดงข้อความเตือนกรอกข้อมูลไม่ครบ
      return;
    }

    await lotteryCollection.add({
      'number': number,
      'price': price,
      'available': true, // สถานะเริ่มต้น: สามารถซื้อได้
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("เพิ่มลอตเตอรี่ $number สำเร็จ")),
    );
    _numberController.clear();
    _priceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เพิ่มลอตเตอรี่')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _numberController,
              decoration: const InputDecoration(labelText: 'หมายเลขลอตเตอรี่'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'ราคา'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addLottery,
              child: const Text('เพิ่มลอตเตอรี่'),
            ),
          ],
        ),
      ),
    );
  }
}
