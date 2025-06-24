import 'package:flutter/material.dart';
import 'package:node_me/resources/hangout_service.dart';

class CreateHangoutDialog extends StatelessWidget {
  final Function(String hangoutId) onHangoutCreated;
  const CreateHangoutDialog({super.key, required this.onHangoutCreated});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    return AlertDialog(
      title: const Text("Create Hangout"),
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(labelText: 'Hangout name'),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final id = await HangoutService().createHangout(
              nameController.text,
            );
            onHangoutCreated(id);
            Navigator.pop(context);
          },
          child: const Text("Create"),
        ),
      ],
    );
  }
}
