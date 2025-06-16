import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:node_me/firebase_options.dart';
import 'package:node_me/screens/enter_phone_number.dart';
import 'package:node_me/screens/enter_profile_details_screen.dart';
import 'package:node_me/screens/home_screen.dart';
import 'package:node_me/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: EnterProfileScreen(uid: '11'),
    );
  }
}
