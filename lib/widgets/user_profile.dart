import 'package:flutter/material.dart';
import 'package:node_me/utils/app_color.dart';
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
      shadowColor: AppColors.graphLine,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
                      Container(
                        padding: EdgeInsets.only(
                          top: 2,
                          bottom: 2,
                          left: 8,
                          right: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '@${user.username}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                CustomSimpleRoundedButton(onPressed: onEdit, text: "Edit"),
              ],
            ),

            const SizedBox(height: 16),

            /// Bio

            /// Friend Count
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (user.bio.isNotEmpty)
                  SizedBox(
                    width: 180,
                    child: Text(
                      user.bio,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),

                Expanded(child: const SizedBox()),

                _buildStat("Friends", user.friends),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user.interests.isNotEmpty)
                  Expanded(
                    child: Wrap(
                      spacing: 2,
                      runSpacing: -10,
                      children: user.interests
                          .map(
                            (interest) => Chip(
                              side: BorderSide(color: AppColors.card),

                              label: Text(
                                interest,
                                style: TextStyle(fontSize: 12),
                              ),
                              backgroundColor: AppColors.secondaryCard,
                            ),
                          )
                          .toList(),
                    ),
                  )
                else
                  const Text(
                    'No interests added yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
              ],
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textMuted)),
      ],
    );
  }
}
