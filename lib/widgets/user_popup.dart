import 'package:flutter/material.dart';

void showUserOptionsPopup(
  BuildContext context,
  String uid,
  VoidCallback onAddToHangout,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("User Options"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('View Profile'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Add profile view action
            },
          ),
          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text('Add to Hangout'),
            onTap: () {
              Navigator.pop(context);
              onAddToHangout();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    ),
  );
}
