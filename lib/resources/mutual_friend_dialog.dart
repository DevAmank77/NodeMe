import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

void showMutualFriendDialog(
  BuildContext context,
  List<String> mutualFriendUids,
  void Function(String selectedUid) onSelect,
) async {
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  // Fetch names for each UID
  List<Map<String, String>> friends = [];

  for (String uid in mutualFriendUids) {
    final snapshot = await db.child('users/$uid/name').get();
    if (snapshot.exists) {
      friends.add({'uid': uid, 'name': snapshot.value.toString()});
    }
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Select Mutual Friend'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(friend['name'] ?? 'Unnamed'),
              onTap: () {
                Navigator.pop(context);
                onSelect(friend['uid']!);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
