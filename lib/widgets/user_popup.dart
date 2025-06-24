import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:node_me/resources/create_hangout_dialog.dart';
import 'package:node_me/resources/hangout_service.dart';

void showUserOptionsPopup(
  BuildContext context,
  String currentUserId,
  String targetUserId,
  VoidCallback onCreateHangout,
  void Function(String hangoutId) onAddToExistingHangout,
) async {
  final hangoutsSnapshot = await FirebaseFirestore.instance
      .collection('hangouts')
      .where('members', arrayContains: currentUserId)
      .get();

  final hasHangouts = hangoutsSnapshot.docs.isNotEmpty;

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
              // Add your navigation logic here
            },
          ),
          if (hasHangouts)
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Add to Existing Hangout'),
              onTap: () {
                Navigator.pop(context);
                _showExistingHangoutSelector(
                  context,
                  hangoutsSnapshot.docs,
                  onAddToExistingHangout,
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text('Create New Hangout'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) =>
                    CreateHangoutDialog(onHangoutCreated: (id) {}),
              );
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

void _showExistingHangoutSelector(
  BuildContext context,
  List<QueryDocumentSnapshot> hangouts,
  void Function(String hangoutId) onSelect,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Select Hangout"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: hangouts.length,
          itemBuilder: (context, index) {
            final hangoutDoc = hangouts[index];
            final hangout = hangoutDoc.data() as Map<String, dynamic>;
            final hangoutId = hangoutDoc.id;

            return ListTile(
              title: Text(hangout['name'] ?? 'Unnamed Hangout'),
              onTap: () async {
                final receiverId =
                    ModalRoute.of(context)!.settings.arguments
                        as String?; // or pass it via parameter

                if (receiverId != null) {
                  await HangoutService().requestAddMember(
                    hangoutId: hangoutId,
                    receiverId: receiverId,
                  );
                }

                Navigator.pop(context);
                onSelect(hangoutId);
              },
            );
          },
        ),
      ),
    ),
  );
}
