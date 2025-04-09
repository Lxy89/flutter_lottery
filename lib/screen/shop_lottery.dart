import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lottery/model/cart_service.dart';

class LotteryShop extends StatefulWidget {
  final String userEmail;

  const LotteryShop({Key? key, required this.userEmail}) : super(key: key);

  @override
  _LotteryShopState createState() => _LotteryShopState();
}

class WelcomeText extends StatelessWidget {
  final String userEmail;

  const WelcomeText({Key? key, required this.userEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      "Welcome: $userEmail!",
      style: TextStyle(fontSize: 24),
    );
  }
}

class LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutButton({Key? key, required this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.logout, color: Colors.red),
      tooltip: "Logout",
      onPressed: onLogout,
    );
  }
}

class _LotteryShopState extends State<LotteryShop> {
  final CollectionReference lotteryCollection =
      FirebaseFirestore.instance.collection('lotteries');

  List<Map<String, dynamic>> cart = [];

  // ฟังก์ชันเพื่อเพิ่มสินค้าในตะกร้า
  void addToCart(String docId, String number, double price) {
    setState(() {
      cart.add({
        'lottery_id': docId,
        'number': number,
        'price': price,
      });
    });
    // บันทึกข้อมูลตะกร้า
    CartService cartService = CartService();
    cartService.saveCart(cart);
  }

  // ฟังก์ชันเพื่อจัดการการซื้อ
  Future<void> buyLottery(String docId, String number, double price) async {
    // เพิ่มในตะกร้าก่อน
    addToCart(docId, number, price);

    await lotteryCollection.doc(docId).update({'available': false});

    // บันทึกการซื้อใน Firestore
    await FirebaseFirestore.instance.collection('purchases').add({
      'lottery_id': docId,
      'number': number,
      'price': price,
      'buyer': widget.userEmail, // ใช้ email ของผู้ใช้ที่ล็อกอิน
      'timestamp': FieldValue.serverTimestamp(),
    });

    // แสดง Dialog ยืนยันการซื้อ
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("การซื้อสำเร็จ"),
          content: Text("คุณได้ซื้อเลข $number ราคา $price บาท"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
              },
              child: Text("ตกลง"),
            ),
          ],
        );
      },
    );

    print("✅ ซื้อสำเร็จ: $docId");
  }

  // ฟังก์ชันเพื่อไปหน้าตะกร้า
  void viewCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(cart: cart),
      ),
    );
  }

// กลับไปหน้า Login
  void logout(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("ออกจากระบบ"),
      content: Text("คุณแน่ใจหรือไม่?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // ปิด Dialog
          child: Text("ยกเลิก"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context); // ปิด Dialog
            FirebaseAuth.instance.signOut(); // ออกจากระบบ
            Navigator.pushReplacementNamed(context, '/login'); // กลับหน้า Login
          },
          child: Text("ออก", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลตะกร้าจาก SharedPreferences
    _loadCart();
  }

  // ฟังก์ชันโหลดข้อมูลตะกร้าจาก SharedPreferences
  Future<void> _loadCart() async {
    CartService cartService = CartService();
    List<Map<String, dynamic>> cartData = await cartService.loadCart();
    setState(() {
      cart = cartData; // อัปเดตข้อมูลตะกร้า
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ร้านค้าลอตเตอรี่'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: viewCart, // ไปที่หน้าตะกร้าสินค้า
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // แสดง WelcomeText widget
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                WelcomeText(userEmail: widget.userEmail),
                SizedBox(width: 8),
                //แสดง widget logOut
               LogoutButton(
                onLogout: () => logout(context)
               ),
              ],
            ),
          ),

          // StreamBuilder สำหรับแสดงรายการลอตเตอรี่
          Expanded(
            child: StreamBuilder(
              stream: lotteryCollection.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("ไม่มีลอตเตอรี่"));
                }

                var lotteries = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                  ),
                  itemCount: lotteries.length,
                  itemBuilder: (context, index) {
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
                            padding: const EdgeInsets.only(right: 4),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton(
                                onPressed: lotteryData['available']
                                    ? () => buyLottery(
                                        lotteryId,
                                        lotteryData['number'],
                                        lotteryData['price'])
                                    : null,
                                child: Text(
                                    lotteryData['available'] ? "ซื้อ" : "หมด"),
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
          ),
        ],
      ),
    );
  }
}

// Cart screen to view selected items
class CartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cart;

  const CartScreen({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    double totalPrice = cart.fold(0, (sum, item) => sum + item['price']);

    return Scaffold(
      appBar: AppBar(
        title: Text("ตะกร้าของคุณ"),
      ),
      body: cart.isEmpty
          ? Center(child: Text("ตะกร้าของคุณว่าง"))
          : ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                var item = cart[index];
                return ListTile(
                  title: Text("เลข ${item['number']}"),
                  subtitle: Text("ราคา: ${item['price']} บาท"),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            // Implement checkout functionality
          },
          child: Text("ไปที่การชำระเงิน (รวม: $totalPrice บาท)"),
        ),
      ),
    );
  }
}
