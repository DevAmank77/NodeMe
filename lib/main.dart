import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:node_me/firebase_options.dart';
import 'package:node_me/resources/check_auth.dart';
import 'package:node_me/utils/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://idzylxkmysvldzqmzylx.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlkenlseGtteXN2bGR6cW16eWx4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAwMjY4MzQsImV4cCI6MjA2NTYwMjgzNH0.gy4JYa0IIgJI1UNVp3arn75Y38iAKSc4CMxAgGn6YFM",
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: CheckAuth(),
    );
  }
}
