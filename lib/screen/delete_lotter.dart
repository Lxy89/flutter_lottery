import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lottery/screen/login_screen.dart';

// สร้างหน้าจอแบบ Stateful เพื่อให้รองรับการเปลี่ยนแปลงสถานะ (เพิ่ม/ลบ/แก้ไขลอตเตอรี่)
class DeleteLottery extends StatefulWidget {
  const DeleteLottery({super.key});

  @override
  _DeleteLotteryState createState() => _DeleteLotteryState(); //รับ key เพื่อให้ Flutter จัดการ widget tree
}

class _DeleteLotteryState extends State<DeleteLottery> {
  final CollectionReference lotteryCollection = FirebaseFirestore.instance.collection('lotteries'); //เชื่อมต่อกับ Collection
  final TextEditingController numberController = TextEditingController();
  final TextEditingController priceController = TextEditingController(); //ควบคุมการกรอกเลขลอตเตอรี่และราคาใน TextField

  // ฟังก์ชันสำหรับเพิ่มลอตเตอรี่
  Future<void> addLottery(String number, double price) async {
    await lotteryCollection.add({
      'number': number,
      'price': price,
      'available': true,
    });

    print("✅ เพิ่มลอตเตอรี่: $number");
  }

// ฟังก์ชันสำหรับแก้ไขลอตเตอรี่
  Future<void> editLottery(
      String docId, String newNumber, double newPrice) async {
    await lotteryCollection.doc(docId).update({
      'number': newNumber,
      'price': newPrice,
    });
  //แก้ไข document ที่มี docId ใน collection lotteries เลขและราคาใหม่ ที่แก้ไขแล้ว
    print("✅ แก้ไขลอตเตอรี่: $docId");
  }

// ฟังก์ชันสำหรับแสดง dialog แก้ไขลอตเตอรี่
  void _showEditLotteryDialog( //ใช้แสดงข้อมูลเดิมใน dialog เพื่อให้ผู้ใช้แก้ไข
      String docId, String currentNumber, double currentPrice) {
    TextEditingController numberController =
        TextEditingController(text: currentNumber);
    TextEditingController priceController =
        TextEditingController(text: currentPrice.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('แก้ไขลอตเตอรี่'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numberController,
                decoration: InputDecoration(labelText: 'เลขลอตเตอรี่'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'ราคา'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
              },
              child: Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                String newNumber = numberController.text;
                double newPrice = double.tryParse(priceController.text) ?? 0.0;
                if (newNumber.isNotEmpty && newPrice > 0) {
                  editLottery(docId, newNumber, newPrice);
                  Navigator.of(context).pop(); // ปิด dialog
                }
              },
              child: Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันสำหรับลบลอตเตอรี่
  Future<void> deleteLottery(String docId) async {
    await lotteryCollection.doc(docId).delete();

    print("✅ ลบลอตเตอรี่: $docId");
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ร้านค้าลอตเตอรี่'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // กลับไปที่หน้า Login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddLotteryDialog();
        },
        tooltip: 'เพิ่มลอตเตอรี่',
        child: Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: lotteryCollection.snapshots(), 
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) { //ตรวจว่าอยู่ในสถานะ "กำลังรอ"
            return const Center(child: CircularProgressIndicator()); //วงกลมหมุน
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("ไม่มีลอตเตอรี่"));
          }

          var lotteries = snapshot.data!.docs; //ดึงรายการลอตเตอรี่ทั้งหมดออกมาเก็บไว้ในตัวแปร

          return GridView.builder(
            padding: const EdgeInsets.all(0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemCount: lotteries.length,
            itemBuilder: (context, index) {
               // ดึงข้อมูลลอตเตอรี่แต่ละตัว
              var lotteryDoc = lotteries[index];
              var lotteryData = lotteryDoc.data() as Map<String, dynamic>;
              String lotteryId = lotteryDoc.id;

              return Card(
                elevation: 3,
                child: Column(
                  children: [
                    ListTile(
                      title: Text("เลข ${lotteryData['number']}"),
                      subtitle: Text("ราคา: ${lotteryData['price']} บาท"),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 1),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            //Edit
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _showEditLotteryDialog(
                                    lotteryId,
                                    lotteryData['number'],
                                    lotteryData['price']);
                              },
                            ),
                            // ปุ่มลบลอตเตอรี่ในแต่ละการ์ด
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _showDeleteConfirmationDialog(lotteryId);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ฟังก์ชันสำหรับแสดง dialog เพื่อเพิ่มลอตเตอรี่
  void _showAddLotteryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เพิ่มลอตเตอรี่'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numberController,
                decoration: InputDecoration(labelText: 'เลขลอตเตอรี่'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'ราคา'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
              },
              child: Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                String number = numberController.text;
                double price = double.tryParse(priceController.text) ?? 0.0;
                if (number.isNotEmpty && price > 0) {
                  addLottery(number, price);
                  numberController.clear();
                  priceController.clear();
                  Navigator.of(context).pop(); // ปิด dialog
                }
              },
              child: Text('เพิ่ม'),
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันสำหรับแสดง dialog ยืนยันการลบ
  void _showDeleteConfirmationDialog(String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ยืนยันการลบ'),
          content: Text('คุณต้องการลบลอตเตอรี่เลขนี้หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
              },
              child: Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                deleteLottery(docId);
                Navigator.of(context).pop(); // ปิด dialog
              },
              child: Text('ยืนยัน'),
            ),
          ],
        );
      },
    );
  }

  // Future<void> buyLottery(String docId, String number, double price) async {
  //   await lotteryCollection.doc(docId).update({'available': false});

  //   // บันทึกข้อมูลการซื้อ
  //   await FirebaseFirestore.instance.collection('purchases').add({
  //     'lottery_id': docId,
  //     'number': number,
  //     'price': price,
  //     'buyer': "user123", // เปลี่ยนเป็น user ID ของผู้ใช้
  //     'timestamp': FieldValue.serverTimestamp(),
  //   });

  //   // แสดงข้อความยืนยันการซื้อ
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("การซื้อสำเร็จ"),
  //         content: Text("คุณได้ซื้อเลข $number ราคา $price บาท"),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(); // ปิด Dialog
  //             },
  //             child: Text("ตกลง"),
  //           ),
  //         ],
  //       );
  //     },
  //   );

  //   print("✅ ซื้อสำเร็จ: $docId");
  // }
}