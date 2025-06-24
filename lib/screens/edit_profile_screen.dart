import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:node_me/widgets/custom_button.dart';
import 'package:node_me/widgets/image_upload.dart';
import '../models/user_model.dart';
import '../utils/app_color.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController interestController;
  late TextEditingController bioController;
  String? updatedProfilePicUrl;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    usernameController = TextEditingController(text: widget.user.username);
    interestController = TextEditingController(
      text: widget.user.interests.join(', '),
    );
    bioController = TextEditingController(text: widget.user.bio);
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedUser = UserModel(
      uid: widget.user.uid,
      name: nameController.text.trim(),
      username: usernameController.text.trim(),
      bio: bioController.text.trim(),
      profilePicUrl: updatedProfilePicUrl ?? widget.user.profilePicUrl,
      friends: widget.user.friends,
      interests: interestController.text
          .split(',')
          .map((e) => e.trim())
          .toList(),
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .update(updatedUser.toJson());

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: ImageUpload(
                  onImageUploaded: (url) {
                    setState(() {
                      updatedProfilePicUrl = url;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Name required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Username required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: interestController,
                decoration: const InputDecoration(labelText: 'Hobbies'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'hobbies is required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              CustomSimpleRoundedButton(
                onPressed: saveProfile,
                text: 'Save Changes',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
