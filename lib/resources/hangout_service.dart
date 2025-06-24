import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<void> requestAddMember({
    required String hangoutId,
    required String receiverId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final isOwner = await FirebaseFirestore.instance
        .collection('hangouts')
        .doc(hangoutId)
        .get()
        .then((doc) => doc.data()?['createdBy'] == user.uid);

    final DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('hangouts')
        .doc(hangoutId)
        .get();

    final String hangoutName =
        (doc.data() as Map<String, dynamic>?)?['name'] ?? 'Unnamed Hangout';
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
    } else {
      // Request to owner first
      final hangoutDoc = await FirebaseFirestore.instance
          .collection('hangouts')
          .doc(hangoutId)
          .get();

      final ownerId = hangoutDoc.data()?['createdBy'];

      await FirebaseFirestore.instance.collection('ownerApprovalRequests').add({
        "hangoutName": hangoutName,
        'hangoutId': hangoutId,
        'from': user.uid,
        'toBeAdded': receiverId,
        'ownerId': ownerId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
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
}
