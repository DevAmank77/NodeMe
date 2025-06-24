import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:node_me/resources/mutual_friend_dialog.dart';
import '../models/hangout_model.dart';

class HangoutService {
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser!;

  Future<String> createHangout(String name) async {
    final doc = await _firestore.collection('hangouts').add({
      'name': name,
      'createdBy': _user.uid,
      'members': [_user.uid],
      'createdAt': DateTime.now(),
    });
    return doc.id;
  }

  Future<List<HangoutModel>> getUserHangouts() async {
    final snapshot = await _firestore
        .collection('hangouts')
        .where('members', arrayContains: _user.uid)
        .get();

    return snapshot.docs
        .map((doc) => HangoutModel.fromJson(doc.id, doc.data()))
        .toList();
  }

  Future<bool> checkIfFriendExists(String userId, String receiverId) async {
    final db = FirebaseDatabase.instance.ref().child(
      'users/$userId/firstDegreeIds/$receiverId',
    );

    final snapshot = await db.get();
    return snapshot.exists;
  }

  Future<void> requestAddMember({
    required BuildContext context,
    required String hangoutId,
    required String receiverId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docSnap = await FirebaseFirestore.instance
        .collection('hangouts')
        .doc(hangoutId)
        .get();

    final data = docSnap.data();
    final isOwner = data?['createdBy'] == user.uid;
    final hangoutName = data?['name'] ?? 'Unnamed Hangout';

    bool exists = await checkIfFriendExists(user.uid, receiverId);
    if (exists) {
      if (isOwner) {
        // Direct request to receiver

        await FirebaseFirestore.instance.collection('hangoutRequests').add({
          "hangoutName": hangoutName,
          'hangoutId': hangoutId,
          'from': user.uid,
          'to': receiverId,
          'status': 'pending',
          'type': 'direct',
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Hangout invite sent directly to friend."),
            backgroundColor: Colors.green,
          ),
        );
        bool approved = await isApprovedByOwner(hangoutId, receiverId);

        if (approved) {
          approvedByOwner(
            hangoutId: hangoutId,
            hangoutName: hangoutName,
            fromUid: user.uid,
            toUid: receiverId,
          );
        }
      } else {
        final ownerId = data?['createdBy'];

        await FirebaseFirestore.instance
            .collection('ownerApprovalRequests')
            .add({
              "hangoutName": hangoutName,
              'hangoutId': hangoutId,
              'from': user.uid,
              'toBeAdded': receiverId,
              'to': ownerId,
              'status': 'pending',
              'timestamp': FieldValue.serverTimestamp(),
            });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "you are not the owner of this hangout. Approval request sent to owner.",
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "this user is not your 1st-degree friend. First take the approval from a 1st-degree mutual friend",
          ),
          backgroundColor: Colors.redAccent,
        ),
      );

      List<String> mutuals = await getMutualFriends('userA', 'userB');

      showMutualFriendDialog(context, mutuals, (selectedUid) {
        print('User selected: $selectedUid');
      });
    }
  }

  Future<String?> removeMember({
    required String hangoutId,
    required String memberUid,
  }) async {
    final currentUser = _user;

    final hangoutDoc = await _firestore
        .collection('hangouts')
        .doc(hangoutId)
        .get();

    if (!hangoutDoc.exists) return "Hangout does not exist";

    final data = hangoutDoc.data();
    final createdBy = data?['createdBy'];

    if (createdBy != currentUser.uid) {
      return "Only the hangout owner can remove members";
    }

    List<dynamic> members = List.from(data?['members'] ?? []);
    if (!members.contains(memberUid)) return "Member not found in this hangout";

    members.remove(memberUid);

    await _firestore.collection('hangouts').doc(hangoutId).update({
      'members': members,
    });

    return null;
  }

  Future<List<String>> getMutualFriends(String userAId, String userBId) async {
    final db = FirebaseDatabase.instance.ref();

    final userAFriendsRef = db.child('users/$userAId/firstDegreeIds');
    final userBFriendsRef = db.child('users/$userBId/firstDegreeIds');

    final userASnapshot = await userAFriendsRef.get();
    final userBSnapshot = await userBFriendsRef.get();

    if (!userASnapshot.exists || !userBSnapshot.exists) return [];

    final Map userAFriends = userASnapshot.value as Map;
    final Map userBFriends = userBSnapshot.value as Map;

    final aIds = userAFriends.keys.toSet();
    final bIds = userBFriends.keys.toSet();

    // Intersection = mutual friends
    final mutualFriends = aIds.intersection(bIds).toList();

    return mutualFriends.cast<String>();
  }

  Future<void> approvedByOwner({
    required String hangoutId,
    required String hangoutName,
    required String fromUid,
    required String toUid,
  }) async {
    await FirebaseFirestore.instance.collection('hangoutRequests').add({
      'hangoutId': hangoutId,
      'hangoutName': hangoutName,
      'from': fromUid,
      'to': toUid,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Delete the approval request as after now processed
    final snapshot = await FirebaseFirestore.instance
        .collection('ownerApprovalRequests')
        .where('toBeAdded', isEqualTo: toUid)
        .where('hangoutId', isEqualTo: hangoutId)
        .where('from', isEqualTo: fromUid)
        .get();

    for (final doc in snapshot.docs) {
      await FirebaseFirestore.instance
          .collection('ownerApprovalRequests')
          .doc(doc.id)
          .delete();
    }
  }

  Future<bool> isApprovedByOwner(String hangoutId, String receiverId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('ownerApprovalRequests')
        .where('hangoutId', isEqualTo: hangoutId)
        .where('toBeAdded', isEqualTo: receiverId)
        .where('status', isEqualTo: 'approved')
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }
}
