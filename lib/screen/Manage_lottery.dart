import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageLotteryPage extends StatefulWidget {
  final String? docId; // docId สำหรับแก้ไขลอตเตอรี่, null หากเป็นการเพิ่ม

  const ManageLotteryPage({super.key, this.docId});

  @override
  _ManageLotteryPageState createState() => _ManageLotteryPageState();
}

class _ManageLotteryPageState extends State<ManageLotteryPage> {
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isAvailable = true;

  final CollectionReference lotteryCollection =
      FirebaseFirestore.instance.collection('lotteries');
  
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    if (widget.docId != null) {
      _isEditing = true;
      _loadLotteryData();
    }
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

  Future<void> _saveLottery() async {
    String number = _numberController.text.trim();
    double price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    if (number.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("กรุณากรอกข้อมูลให้ครบถ้วน")),
      );
      return;
    }

    if (_isEditing) {
      // การแก้ไขลอตเตอรี่
      await lotteryCollection.doc(widget.docId).update({
        'number': number,
        'price': price,
        'available': _isAvailable,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("แก้ไขลอตเตอรี่ $number สำเร็จ")),
      );
    } else {
      // การเพิ่มลอตเตอรี่ใหม่
      await lotteryCollection.add({
        'number': number,
        'price': price,
        'available': true, // สถานะเริ่มต้น: สามารถซื้อได้
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เพิ่มลอตเตอรี่ $number สำเร็จ")),
      );
    }
    _numberController.clear();
    _priceController.clear();
    Navigator.pop(context);
  }

  Future<void> _deleteLottery() async {
    if (_isEditing) {
      await lotteryCollection.doc(widget.docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ลบลอตเตอรี่ ${_numberController.text} สำเร็จ")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'แก้ไขลอตเตอรี่' : 'เพิ่มลอตเตอรี่'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteLottery,
            ),
        ],
      ),
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
              onPressed: _saveLottery,
              child: Text(_isEditing ? 'บันทึกการแก้ไข' : 'เพิ่มลอตเตอรี่'),
            ),
          ],
        ),
      ),
    );
  }
}
