import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PurchaseHistoryScreen extends StatelessWidget {
  final String userEmail;

  const PurchaseHistoryScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ประวัติการซื้อ"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('purchases')
            .where('buyer', isEqualTo: userEmail)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("ไม่มีประวัติการซื้อ"));
          }

          var purchases = snapshot.data!.docs;

          return ListView.builder(
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              var purchaseData = purchases[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text("เลข ${purchaseData['number']}"),
                  subtitle: Text("ราคา: ${purchaseData['price']} บาท"),
                  trailing: Text(
                    "${purchaseData['timestamp'].toDate()}",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}