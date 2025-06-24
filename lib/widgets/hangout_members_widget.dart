import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HangoutMembersWidget extends StatelessWidget {
  final String hangoutId;

  const HangoutMembersWidget({super.key, required this.hangoutId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('hangouts')
          .doc(hangoutId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final List members = data['members'] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Members:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...members.map((uid) => Text('• $uid')).toList(),
          ],
        );
      },
    );
  }
}
