import 'package:flutter/material.dart';
import '../models/user_model.dart';

class EnterProfileScreen extends StatefulWidget {
  final String uid; // comes from Firebase Auth

  const EnterProfileScreen({super.key, required this.uid});

  @override
  State<EnterProfileScreen> createState() => _EnterProfileScreenState();
}

class _EnterProfileScreenState extends State<EnterProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController profilePicController = TextEditingController();

  bool isLoading = false;

  void saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final user = UserModel(
      uid: widget.uid,
      name: nameController.text.trim(),
      username: usernameController.text.trim(),
      bio: bioController.text.trim(),
      profilePicUrl: profilePicController.text.trim(),
      interests: [],
    );

    // Save to Firebase or DB here
    // await FirebaseFirestore.instance.collection('users').doc(widget.uid).set(user.toJson());

    setState(() {
      isLoading = false;
    });

    Navigator.pushReplacementNamed(context, '/home'); // change as needed
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
                backgroundImage: profilePicController.text.isNotEmpty
                    ? NetworkImage(profilePicController.text)
                    : null,
                child: profilePicController.text.isEmpty
                    ? const Icon(Icons.person, size: 50)
                    : null,
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
                controller: profilePicController,
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
              ElevatedButton(
                onPressed: isLoading ? null : saveProfile,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
