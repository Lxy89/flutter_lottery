import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditLotteryPage extends StatefulWidget {
  final String docId; // ID ของเอกสารลอตเตอรี่ที่ต้องการแก้ไข

  const EditLotteryPage({super.key, required this.docId});

  @override
  _EditLotteryPageState createState() => _EditLotteryPageState();
}

class _EditLotteryPageState extends State<EditLotteryPage> {
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isAvailable = true;

  final CollectionReference lotteryCollection =
      FirebaseFirestore.instance.collection('lotteries');

  @override
  void initState() {
    super.initState();
    _loadLotteryData();
  }

  Future<void> _loadLotteryData() async {
    DocumentSnapshot doc = await lotteryCollection.doc(widget.docId).get();
    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;
      _numberController.text = data['number'];
      _priceController.text = data['price'].toString();
      _isAvailable = data['available'];
    }
  }

  Future<void> updateLottery() async {
    String number = _numberController.text.trim();
    double price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    if (number.isEmpty || price <= 0) {
      // แสดงข้อความเตือนกรอกข้อมูลไม่ครบ
      return;
    }

    await lotteryCollection.doc(widget.docId).update({
      'number': number,
      'price': price,
      'available': _isAvailable,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("แก้ไขลอตเตอรี่ $number สำเร็จ")),
    );
    Navigator.pop(context); // กลับไปที่หน้าเดิม
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แก้ไขลอตเตอรี่')),
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
            Row(
              children: [
                Text("สถานะ: "),
                Switch(
                  value: _isAvailable,
                  onChanged: (value) {
                    setState(() {
                      _isAvailable = value;
                    });
                  },
                ),
                Text(_isAvailable ? 'สามารถซื้อได้' : 'ขายแล้ว'),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateLottery,
              child: const Text('แก้ไขลอตเตอรี่'),
            ),
          ],
        ),
      ),
    );
  }
}
