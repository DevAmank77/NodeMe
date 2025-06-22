import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:node_me/resources/friend_service.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  List<Map<String, dynamic>> _requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  Future<void> loadRequests() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    final snapshot = await FriendService().getIncomingRequests(currentUid);

    setState(() {
      _requests = snapshot;
      isLoading = false;
    });
  }

  Future<void> handleAccept(Map<String, dynamic> req) async {
    await FriendService().acceptFriendRequest(
      requestId: req['requestId'],
      fromId: req['senderUid'],
      toId: req['receiverUid'],
    );

    setState(() {
      _requests.removeWhere((r) => r['requestId'] == req['requestId']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Friend Requests")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
          ? const Center(child: Text("No pending requests"))
          : ListView.builder(
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final req = _requests[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text("From: ${req['senderUid']}"),
                  subtitle: Text("Status: ${req['status']}"),
                  trailing: TextButton(
                    onPressed: () => handleAccept(req),
                    child: const Text("Accept"),
                  ),
                );
              },
            ),
    );
  }
}
