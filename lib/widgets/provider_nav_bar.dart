import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class ProviderBottomNavigationBarWrapper extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ProviderBottomNavigationBarWrapper({super.key, required this.currentIndex, required this.onTap});

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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_sharp),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_rounded),
            label: 'Orders',
          ),
        ],
      ),
    );
  }
}
