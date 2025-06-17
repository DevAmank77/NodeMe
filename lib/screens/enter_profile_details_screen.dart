import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:node_me/screens/home_screen.dart';
import 'package:node_me/widgets/auth_button.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EnterProfileScreen extends StatefulWidget {
  const EnterProfileScreen({super.key});

  @override
  State<EnterProfileScreen> createState() => _EnterProfileScreenState();
}

class _EnterProfileScreenState extends State<EnterProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final String uid;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController interestController = TextEditingController();

  bool isLoading = false;

  void saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': nameController.text,
          'username': usernameController.text,

          'interests': interestController.text
              .split(',')
              .map((e) => e.trim())
              .toList(),
          'bio': bioController.text,
        });
      }
    }

    setState(() {
      isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: const Text("Create Your Profile"))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,

                child: const Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Name cannot be empty" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Username cannot be empty" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: interestController,
                decoration: const InputDecoration(
                  labelText: "Hobbies(seperated by commas)",
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
                validator: (value) =>
                    value!.isEmpty ? "Please enter Hobbies" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Bio",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Bio cannot be empty" : null,
              ),
              const SizedBox(height: 30),
              CustomSimpleRoundedButton(
                onPressed: isLoading ? () {} : saveProfile,
                text: isLoading ? "Saving..." : "Save Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
