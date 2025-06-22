import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseGraphService {
  static Future<Map<String, List<String>>> fetchFriendGraph() async {
    final dbRef = FirebaseDatabase.instance.ref();
    final snapshot = await dbRef.child('users').get();
    final Map<String, List<String>> tempGraph = {};

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      for (var entry in data.entries) {
        final uid = entry.key;
        final userData = Map<String, dynamic>.from(entry.value);
        final friendsMap = Map<String, dynamic>.from(
          userData['firstDegreeIds'] ?? {},
        );
        tempGraph[uid] = List<String>.from(friendsMap.keys);
      }
    }

    return tempGraph;
  }

  static Future<Map<String, String>> fetchUserNames(List<String> uids) async {
    final firestore = FirebaseFirestore.instance;
    final docs = await firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: uids)
        .get();

    return {for (var doc in docs.docs) doc.id: doc.data()['name'] ?? doc.id};
  }

  static Future<void> sendHangoutRequest(
    String friendUid,
    String message,
  ) async {
    final dbRef = FirebaseDatabase.instance.ref();
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    final requestRef = dbRef.child('hangout_requests').push();
    await requestRef.set({
      'senderUid': currentUid,
      'receiverUid': friendUid,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'pending',
    });
  }
}
