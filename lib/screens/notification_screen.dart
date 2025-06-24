import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:node_me/models/user_model.dart';
import 'package:node_me/resources/friend_service.dart';
import 'package:node_me/screens/screens.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final currentUser = FirebaseAuth.instance.currentUser?.uid;
  int friendReqCount = 0;
  int hangoutReqCount = 0;
  int approvalReqCount = 0;

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    final friendSnapshot = await FirebaseDatabase.instance
        .ref()
        .child('friend_requests')
        .get();

    int friendCount = 0;
    final friendData = (friendSnapshot.value as Map?) ?? {};
    friendData.forEach((key, value) {
      final req = Map<String, dynamic>.from(value);
      if (req['receiverUid'] == currentUser && req['status'] == 'pending') {
        friendCount++;
      }
    });

    final hangoutSnapshot = await FirebaseFirestore.instance
        .collection('hangoutRequests')
        .where('to', isEqualTo: currentUser)
        .where('status', isEqualTo: "pending")
        .get();

    final approvalSnapshot = await FirebaseFirestore.instance
        .collection('ApprovalRequests')
        .where('to', isEqualTo: currentUser)
        .where('status', isEqualTo: "pending")
        .get();

    setState(() {
      friendReqCount = friendCount;
      hangoutReqCount = hangoutSnapshot.docs.length;
      approvalReqCount = approvalSnapshot.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Screens()),
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 16),
            ToggleButtons(
              isSelected: [
                selectedIndex == 0,
                selectedIndex == 1,
                selectedIndex == 2,
              ],
              onPressed: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(10),
              fillColor: Colors.blue.shade100,
              selectedColor: Colors.blue,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text("Hangout"),
                      if (hangoutReqCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: Text(
                            hangoutReqCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text("Approval"),
                      if (approvalReqCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: Text(
                            approvalReqCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text("Friend"),
                      if (friendReqCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: Text(
                            friendReqCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: selectedIndex == 0
                  ? _buildHangoutRequests()
                  : selectedIndex == 1
                  ? _buildApprovalRequests()
                  : _buildFriendRequests(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalRequests() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('ApprovalRequests')
          .where('to', isEqualTo: currentUser)
          .where('status', isEqualTo: "pending")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final approvals = snapshot.data!.docs;
        if (approvals.isEmpty) return const Text("No approval requests.");

        return ListView.builder(
          itemCount: approvals.length,
          itemBuilder: (context, index) {
            final req = approvals[index];
            final hangoutName = req['hangoutName'];
            final fromUid = req['from'];
            final toBeAdded = req['toBeAdded'];
            final docId = req.id;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(toBeAdded)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const ListTile(title: Text("Loading..."));
                }

                final userData = userSnapshot.data!;
                final name = userData['name'] ?? 'Unknown';
                final profilePic = userData['profilePicUrl'] ?? '';

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: profilePic.isNotEmpty
                          ? NetworkImage(profilePic)
                          : null,
                      child: profilePic.isEmpty ? Icon(Icons.person) : null,
                    ),
                    title: Text("Approve $name for $hangoutName"),
                    subtitle: Text("Requested by: $fromUid"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('ApprovalRequests')
                                .doc(docId)
                                .update({'status': 'approved'});
                            await _fetchCounts();
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('ApprovalRequests')
                                .doc(docId)
                                .delete();

                            await _fetchCounts();
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHangoutRequests() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('hangoutRequests')
          .where('to', isEqualTo: currentUser)
          .where('status', isEqualTo: "pending")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final hangouts = snapshot.data!.docs;

        if (hangouts.isEmpty) {
          return const Center(child: Text("No Hangout Requests"));
        }

        return ListView.builder(
          itemCount: hangouts.length,
          itemBuilder: (context, index) {
            final reqDoc = hangouts[index];
            final req = reqDoc.data();
            final hangoutId = req['hangoutId'];
            final fromUid = req['from'];
            final hangoutName = req['hangoutName'];
            final docId = reqDoc.id;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(fromUid)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const ListTile(title: Text("Loading..."));
                }

                final userData = userSnapshot.data!;
                final name = userData['name'] ?? 'Unknown';
                final profilePic = userData['profilePicUrl'] ?? '';

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: profilePic.isNotEmpty
                          ? NetworkImage(profilePic)
                          : null,
                      child: profilePic.isEmpty ? Icon(Icons.person) : null,
                    ),
                    title: Text("Hangout: $hangoutName"),
                    subtitle: Text("From: $name"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('hangouts')
                                .doc(hangoutId)
                                .update({
                                  'members': FieldValue.arrayUnion([
                                    currentUser,
                                  ]),
                                });
                            await FirebaseFirestore.instance
                                .collection('hangoutRequests')
                                .doc(docId)
                                .delete();

                            await _fetchCounts();
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('hangoutRequests')
                                .doc(docId)
                                .delete();

                            await _fetchCounts();
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFriendRequests() {
    return FutureBuilder<DataSnapshot>(
      future: FirebaseDatabase.instance.ref('friend_requests').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = (snapshot.data?.value as Map?) ?? {};

        final requests = data.entries
            .map(
              (entry) =>
                  MapEntry(entry.key, Map<String, dynamic>.from(entry.value)),
            )
            .where(
              (entry) =>
                  entry.value['receiverUid'] == currentUser &&
                  entry.value['status'] == 'pending',
            )
            .toList();

        if (requests.isEmpty) {
          return const Center(child: Text("No Friend Requests"));
        }

        final senderUids = requests
            .map((entry) => entry.value['senderUid'] as String)
            .toSet();

        return FutureBuilder<List<UserModel>>(
          future: fetchUsersByUids(senderUids.toList()),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final users = userSnapshot.data ?? [];
            final userMap = {for (var user in users) user.uid: user};

            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index].value;
                final fromUid = req['senderUid'];
                final sender = userMap[fromUid];

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          sender?.profilePicUrl != null &&
                              sender!.profilePicUrl.isNotEmpty
                          ? NetworkImage(sender.profilePicUrl)
                          : const AssetImage('assets/default_avatar.png')
                                as ImageProvider,
                      radius: 24,
                    ),
                    title: Text(
                      sender?.name ?? 'Unknown User',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Friend request from ${sender?.username ?? fromUid}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            await FriendService().acceptFriendRequest(
                              fromId: fromUid,
                              toId: currentUser ?? '',
                            );
                            final requestKey = requests[index].key;
                            await FirebaseDatabase.instance
                                .ref('friend_requests/$requestKey')
                                .remove();
                            await _fetchCounts();
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            final requestKey = requests[index].key;
                            await FirebaseDatabase.instance
                                .ref('friend_requests/$requestKey')
                                .remove();
                            await _fetchCounts();
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

Future<List<UserModel>> fetchUsersByUids(List<String> uids) async {
  if (uids.isEmpty) return [];

  final userCollection = FirebaseFirestore.instance.collection('users');

  List<UserModel> allUsers = [];

  for (int i = 0; i < uids.length; i += 10) {
    final batch = uids.sublist(i, i + 10 > uids.length ? uids.length : i + 10);
    final snapshot = await userCollection
        .where(FieldPath.documentId, whereIn: batch)
        .get();

    final users = snapshot.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .toList();

    allUsers.addAll(users);
  }

  return allUsers;
}
