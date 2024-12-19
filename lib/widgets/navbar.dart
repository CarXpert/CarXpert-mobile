import 'package:flutter/material.dart';

class MyBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  const MyBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onItemTapped,
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
        BottomNavigationBarItem(
          icon : Icon(Icons.newspaper),
          label: "News"
        ),
      ],
    );
  }
}
