import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:node_me/models/user_model.dart';

class FriendService {
  final db = FirebaseDatabase.instance.ref();

  Future<void> acceptFriendRequest({
    required String requestId,
    required String fromId,
    required String toId,
  }) async {
    final updates = <String, dynamic>{};
    final timestamp = DateTime.now().toIso8601String();

    updates['friend_requests/$toId/$requestId/status'] = 'accepted';
    updates['friend_requests/$toId/$requestId/acceptedAt'] = timestamp;

    updates['users/$fromId/firstDegreeIds/$toId'] = true;
    updates['users/$toId/firstDegreeIds/$fromId'] = true;

    try {
      await db.update(updates);
    } catch (e) {
      print('Error accepting friend request: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getIncomingRequests(
    String currentUid,
  ) async {
    final snapshot = await db.child('friend_requests').get();
    final data = (snapshot.value as Map?) ?? {};

    final List<Map<String, dynamic>> requests = [];

    data.forEach((key, value) {
      if (value['receiverUid'] == currentUid && value['status'] == 'pending') {
        requests.add({...value, 'requestId': key});
      }
    });

    return requests;
  }

  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return UserModel.fromJson(data);
    }).toList();
  }

  Future<bool> sendFriendRequest(
    String receiverUid,
    BuildContext context,
  ) async {
    final senderUid = FirebaseAuth.instance.currentUser?.uid;
    if (senderUid == null || senderUid == receiverUid) return false;

    final sortedUids = [senderUid, receiverUid]..sort();
    final requestKey = '${sortedUids[0]}_${sortedUids[1]}';

    final requestRef = db.child('friend_requests').child(requestKey);

    final snapshot = await requestRef.get();
    if (snapshot.exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Friend request already sent')));
      return false;
    }

    await requestRef.set({
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'status': 'pending',
      'timestamp': DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Friend request sent')));
    return true;
  }

  Future<bool> unsendFriendRequest(
    String receiverUid,
    BuildContext context,
  ) async {
    final senderUid = FirebaseAuth.instance.currentUser?.uid;

    if (senderUid == null || senderUid == receiverUid) return false;

    final sortedUids = [senderUid, receiverUid]..sort();
    final requestKey = '${sortedUids[0]}_${sortedUids[1]}';

    final requestRef = db.child('friend_requests').child(requestKey);

    final snapshot = await requestRef.get();
    if (snapshot.exists) {
      await requestRef.remove();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Friend requestunsend')));
      return true;
    }

    return false;
  }

  Future<Set<String>> getSentFriendRequests() async {
    final senderUid = FirebaseAuth.instance.currentUser?.uid;
    final snapshot = await db.child('friend_requests').get();

    final data = (snapshot.value as Map?) ?? {};

    final sentUids = <String>{};

    data.forEach((key, value) {
      if (value['senderUid'] == senderUid && value['status'] == 'pending') {
        sentUids.add(value['receiverUid']);
      }
    });

    return sentUids;
  }

  Future<List<Map<String, dynamic>>> getHangouts(String currentUid) async {
    final snapshot = await db.child('hangout_requests').get();
    final data = (snapshot.value as Map?) ?? {};

    final List<Map<String, dynamic>> requests = [];

    data.forEach((key, value) {
      if (value is Map &&
          value['receiverUid'] == currentUid &&
          value['status'] == 'pending') {
        requests.add({
          'requestId': key,
          'senderUid': value['senderUid'],
          'receiverUid': value['receiverUid'],
          'status': value['status'],
          'message': value['message'] ?? '',
          'timestamp': value['timestamp'] ?? '',
        });
      }
    });

    return requests;
  }

  Future<void> acceptHangoutRequest({
    required String requestId,
    required String fromId,
    required String toId,
  }) async {
    final dbRef = FirebaseDatabase.instance.ref();

    // 1. Update status to 'accepted'
    await dbRef.child('hangout_requests/$requestId').update({
      'status': 'accepted',
      'acceptedAt': DateTime.now().toIso8601String(),
    });

    // 2. Add to both users' hangoutMembers
    final updates = <String, dynamic>{
      'hangouts/$fromId/$toId': true,
      'hangouts/$toId/$fromId': true,
    };

    await dbRef.update(updates);
  }
}
