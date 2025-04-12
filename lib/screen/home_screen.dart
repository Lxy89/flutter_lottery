import 'package:flutter/material.dart';
import 'package:flutter_lottery/screen/History_Screen.dart';
import 'package:flutter_lottery/screen/shop_lottery.dart';
import 'package:flutter_lottery/screen/search_lotter.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail;

  const HomeScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      LotteryShop(userEmail: widget.userEmail),
      const SearchLotteryScreen(),
      PurchaseHistoryScreen(userEmail: widget.userEmail)
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromARGB(255, 96, 48, 128),
        unselectedItemColor: const Color.fromARGB(255, 105, 105, 105),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
         ),
        ],
      ),
    );
  }
}