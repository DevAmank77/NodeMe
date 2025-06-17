import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:node_me/screens/enter_phone_number.dart';
import 'package:node_me/screens/home_screen.dart';

class CheckAuth extends StatelessWidget {
  const CheckAuth({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return const HomeScreen();
    } else {
      return const EnterPhoneNumber();
    }
  }
}
