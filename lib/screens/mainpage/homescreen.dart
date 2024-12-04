// car_xpert/screens/mainpage/homescreen.dart

import 'package:flutter/material.dart';
import 'package:car_xpert/widgets/navbar.dart';
import 'package:car_xpert/screens/wishlist/wishlistpage.dart';  
import 'package:car_xpert/screens/comparecars/compare.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text("Home Page", style: TextStyle(fontSize: 18))),
    const Center(child: Text("Bookings Page", style: TextStyle(fontSize: 18))),
    // Anda bisa menambahkan halaman lain atau placeholder jika diperlukan
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WishlistPage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CarComparisonPage()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Xpert"),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: MyBottomNavBar(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
