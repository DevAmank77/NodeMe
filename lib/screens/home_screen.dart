import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:node_me/screens/add_friends_screen.dart';
import 'package:node_me/screens/enter_phone_number.dart';
import 'package:node_me/screens/graph_view_screen.dart';
import 'package:node_me/utils/app_color.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        shadowColor: AppColors.graphLine,

        title: Text(
          'Node Me',
          style: TextStyle(
            fontFamily: GoogleFonts.satisfy().fontFamily,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => EnterPhoneNumber()),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.add_box),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddFriendsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(10),
          child: FriendGraphScreen(),
        ),
      ),
    );
  }
}
