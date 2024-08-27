import 'package:flutter/material.dart';

class UserBottomNavigationBarWrapper extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  UserBottomNavigationBarWrapper({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF0D0A35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 6,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Color(0xFF0D0A35),
        selectedItemColor: Theme.of(context).brightness == Brightness.dark ? const Color.fromRGBO(255, 198, 50, 1.0) : const Color(0xFF0D0A35),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index != currentIndex) {
            onTap(index);
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}