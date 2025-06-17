import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageUpload extends StatefulWidget {
  const ImageUpload({super.key});

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  File? _imageFile;

  Future pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
      uploadImage();
    }
  }

  Future uploadImage() async {
    if (_imageFile == null) return;
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'uploads/$fileName';
    await Supabase.instance.client.storage
        .from('images')
        .upload(path, _imageFile!)
        .then(
          (value) => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('image upload is succcessful')),
          ),
        );

    final profilePicUrl = Supabase.instance.client.storage
        .from('images')
        .getPublicUrl(path);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'profilePicUrl': profilePicUrl},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        pickImage();
      },
      child: CircleAvatar(
        radius: 50,
        backgroundImage: _imageFile != null
            ? FileImage(_imageFile!)
            : const NetworkImage("https://i.pravatar.cc/300"),

        child: Align(
          alignment: Alignment.bottomRight,
          child: CircleAvatar(
            backgroundColor: const Color.fromARGB(255, 81, 81, 81),
            radius: 14,
            child: const Icon(
              Icons.edit,
              size: 16,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ),
      ),
    );
  }
}
