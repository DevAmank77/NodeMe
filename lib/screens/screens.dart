import 'package:flutter/material.dart';
import 'package:node_me/screens/home_screen.dart';
import 'package:node_me/screens/hangouts_screen.dart';
import 'package:node_me/screens/user_profile_screen.dart';

class Screens extends StatefulWidget {
  const Screens({super.key});

  @override
  State<Screens> createState() => _ScreensState();
}

class _ScreensState extends State<Screens> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    HangoutRequestsScreen(),
    UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        iconSize: 20,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),

          BottomNavigationBarItem(
            icon: Icon(Icons.connect_without_contact),
            label: 'Hangouts',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        ],
      ),
    );
  }
}
