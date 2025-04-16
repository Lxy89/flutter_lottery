import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchLotteryScreen extends StatefulWidget {
  const SearchLotteryScreen({super.key});

  @override
  _SearchLotteryScreenState createState() => _SearchLotteryScreenState();
}

class _SearchLotteryScreenState extends State<SearchLotteryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

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
}

void main() {
  runApp(MaterialApp(
    home: SearchLotteryScreen(),
  ));
}