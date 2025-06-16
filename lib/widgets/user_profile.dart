import 'package:flutter/material.dart';
import 'package:node_me/widgets/auth_button.dart';
import '../models/user_model.dart';

class UserProfileCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;

  const UserProfileCard({super.key, required this.user, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Profile Photo + Name + Button
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundImage: NetworkImage(user.profilePicUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user.username}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    CustomSimpleRoundedButton(onPressed: onEdit, text: "Edit"),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Bio
            if (user.bio.isNotEmpty)
              Text(user.bio, style: const TextStyle(fontSize: 14)),

            const SizedBox(height: 16),

            /// Friend Count
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_buildStat("Friends", user.friends)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int count) {
    return Column(
      children: [
        Text(
          "$count",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
