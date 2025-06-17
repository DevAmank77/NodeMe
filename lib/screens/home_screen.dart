import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:node_me/utils/app_color.dart';
import 'package:node_me/widgets/user_profile.dart';
import '../models/user_model.dart';
import 'edit_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<UserModel?> futureUser;

  @override
  void initState() {
    super.initState();
    futureUser = fetchUser();
  }

  Future<UserModel?> fetchUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (snapshot.exists) {
      return UserModel.fromJson(snapshot.data()!);
    }
    return null;
  }

  void refreshUser() {
    setState(() {
      futureUser = fetchUser();
    });
  }

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
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),

          IconButton(icon: const Icon(Icons.add_box), onPressed: () {}),
        ],
      ),
      body: FutureBuilder<UserModel?>(
        future: futureUser,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final user = snapshot.data!;
          return UserProfileCard(
            user: user,
            onEdit: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(user: user),
                ),
              );

              if (result == true) {
                refreshUser(); // Rebuild with updated data
              }
            },
          );
        },
      ),
    );
  }
}
