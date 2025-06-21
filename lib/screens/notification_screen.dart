import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:node_me/resources/friend_service.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  List<Map<String, dynamic>> _friendRequests = [];
  List<Map<String, dynamic>> _hangoutRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAllRequests();
  }

  Future<void> loadAllRequests() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    final friends = await FriendService().getIncomingRequests(currentUid);
    final hangouts = await FriendService().getHangouts(currentUid);

    setState(() {
      _friendRequests = friends;
      _hangoutRequests = hangouts;
      isLoading = false;
    });
  }

  Future<void> handleAcceptFriend(Map<String, dynamic> req) async {
    await FriendService().acceptFriendRequest(
      requestId: req['requestId'],
      fromId: req['senderUid'],
      toId: req['receiverUid'],
    );

    setState(() {
      _friendRequests.removeWhere((r) => r['requestId'] == req['requestId']);
    });
  }

  Future<void> handleAcceptHangout(Map<String, dynamic> req) async {
    await FriendService().acceptHangoutRequest(
      requestId: req['requestId'],
      fromId: req['senderUid'],
      toId: req['receiverUid'],
    );

    setState(() {
      _hangoutRequests.removeWhere((r) => r['requestId'] == req['requestId']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Requests")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                if (_friendRequests.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Friend Requests",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ..._friendRequests.map(
                    (req) => ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text("From: ${req['senderUid']}"),
                      subtitle: Text("Status: ${req['status']}"),
                      trailing: TextButton(
                        onPressed: () => handleAcceptFriend(req),
                        child: const Text("Accept"),
                      ),
                    ),
                  ),
                ],
                if (_hangoutRequests.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Hangout Requests",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ..._hangoutRequests.map(
                    (req) => ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.group)),
                      title: Text("From: ${req['senderUid']}"),
                      subtitle: Text("Message: ${req['message']}"),
                      trailing: TextButton(
                        onPressed: () => handleAcceptHangout(req),
                        child: const Text("Join"),
                      ),
                    ),
                  ),
                ],
                if (_friendRequests.isEmpty && _hangoutRequests.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text("No pending requests"),
                    ),
                  ),
              ],
            ),
    );
  }
}
