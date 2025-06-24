import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:node_me/screens/screens.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool showHangout = true;

  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Screens()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          ToggleButtons(
            isSelected: [showHangout, !showHangout],
            onPressed: (index) {
              setState(() {
                showHangout = index == 0;
              });
            },
            borderRadius: BorderRadius.circular(10),
            fillColor: Colors.blue.shade100,
            selectedColor: Colors.blue,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Hangout Requests"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Friend Requests"),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: showHangout
                ? _buildHangoutRequests()
                : _buildFriendRequests(),
          ),
        ],
      ),
    );
  }

  Widget _buildHangoutRequests() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('hangoutRequests')
          .where('to', isEqualTo: currentUser?.uid)
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

            return Card(
              child: ListTile(
                title: Text("Hangout: $hangoutName"),
                subtitle: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(fromUid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("Loading...");
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Text("Unknown creator");
                    }

                    final name = snapshot.data!.get('name') ?? "Unnamed";
                    return Text("from: $name");
                  },
                ),
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
                                currentUser!.uid,
                              ]),
                            });

                        // Delete the request after accepting
                        await FirebaseFirestore.instance
                            .collection('hangoutRequests')
                            .doc(docId)
                            .delete();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        // Just delete the request (rejected)
                        await FirebaseFirestore.instance
                            .collection('hangoutRequests')
                            .doc(docId)
                            .delete();
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
  }

  Widget _buildFriendRequests() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('friend_requests')
          .where('receiverUid', isEqualTo: currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final requests = snapshot.data!.docs;

        if (requests.isEmpty)
          return const Center(child: Text("No Friend Requests"));

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index].data();
            return Card(
              child: ListTile(
                title: Text("Friend request from ${req['senderUid']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        // TODO: Accept friend request
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        // TODO: Reject friend request
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
  }
}
