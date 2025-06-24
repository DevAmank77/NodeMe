import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void showMutualFriendDialog(
  BuildContext context,
  List<String> mutualFriendUids,
  void Function(String selectedUid) onSelect,
) async {
  List<Map<String, String>> friends = [];
  for (String uid in mutualFriendUids) {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (snapshot.exists) {
        final data = snapshot.data();
        friends.add({'uid': uid, 'name': data?['name'] ?? 'Unnamed'});
      }
    } catch (e) {
      debugPrint("Error fetching name for $uid: $e");
    }
  }

  if (friends.isEmpty) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("No Mutual Friends"),
          content: const Text("You don't have any mutual friends."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
    return;
  }

  if (context.mounted) {
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
}
