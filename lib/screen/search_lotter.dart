import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchLotteryScreen extends StatefulWidget {
  const SearchLotteryScreen({super.key});

  @override
  _SearchLotteryScreenState createState() => _SearchLotteryScreenState();
}

class _SearchLotteryScreenState extends State<SearchLotteryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isAdmin = false;

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  void _checkAdminStatus() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        isAdmin = userDoc.exists && userDoc['role'] == 'admin';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Lottery")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search Lottery Number",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      searchQuery = searchController.text;
                    });
                  },
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _firestore.collection('lotteries')
                  .where('number', isGreaterThanOrEqualTo: searchQuery)
                  .where('number', isLessThanOrEqualTo: '$searchQuery\uf8ff')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final lotteries = snapshot.data!.docs;

                if (lotteries.isEmpty) {
                  return Center(child: Text("No lottery found for '$searchQuery'"));
                }

                return ListView(
                  children: lotteries.map((doc) {
                    return ListTile(
                      title: Text("Number: ${doc['number']}"),
                      subtitle: Text("Price: ${doc['price']} Baht"),
                      trailing: isAdmin
                          ? IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteLottery(doc.id);
                              },
                            )
                          : null,
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _deleteLottery(String id) async {
    await _firestore.collection('lotteries').doc(id).delete();
  }
}

void main() {
  runApp(MaterialApp(
    home: SearchLotteryScreen(),
  ));
}
