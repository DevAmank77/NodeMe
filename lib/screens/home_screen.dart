import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:node_me/models/user_model.dart';
import 'package:node_me/widgets/user_profile.dart';
import 'package:node_me/utils/app_color.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    UserModel testUser = UserModel(
      uid: '123abc',
      name: 'Aman Kumar',
      username: 'amank77',
      bio: 'Flutter developer | Designer | Coffee lover ☕️',

      friends: 42,
      interests: [],
    );

    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Node Me',
            style: TextStyle(
              fontFamily: GoogleFonts.satisfy().fontFamily,
              fontSize: 24,
            ),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),

          IconButton(icon: const Icon(Icons.add_box), onPressed: () {}),
        ],
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            UserProfileCard(
              user: testUser,
              onEdit: () {
                print("Accepted or Edit pressed!");
              },
            ),

            Text(
              'Welcome to Node Me',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add your button action here
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
