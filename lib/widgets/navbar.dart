import 'package:flutter/material.dart';
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
    const Center(child: Text("Placeholder for Wishlist")),
    const Center(child: Text("Placeholder for Compare Page")),
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
        MaterialPageRoute(builder: (context) => CarComparisonPage()), // Navigasi ke compare.dart
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Bookings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "WishList",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: "Compare",
          ),
        ],
      ),
    );
  }
}
