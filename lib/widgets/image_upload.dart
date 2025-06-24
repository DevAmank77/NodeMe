import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageUpload extends StatefulWidget {
  final Function(String)? onImageUploaded;
  const ImageUpload({super.key, this.onImageUploaded});

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  File? _imageFile;
  String? _uploadedUrl;

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

    setState(() {
      _uploadedUrl = profilePicUrl;
    });

    if (widget.onImageUploaded != null) {
      widget.onImageUploaded!(profilePicUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get(),
      builder: (context, snapshot) {
        String? profileUrl;

        if (snapshot.hasData && snapshot.data!.exists) {
          profileUrl = snapshot.data!.get('profilePicUrl');
        }

        return GestureDetector(
          onTap: () {
            pickImage();
          },
          child: CircleAvatar(
            radius: 50,
            backgroundImage: _imageFile != null
                ? FileImage(_imageFile!)
                : (profileUrl != null
                          ? NetworkImage(profileUrl)
                          : const NetworkImage(""))
                      as ImageProvider,
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
      },
    );
  }
}
