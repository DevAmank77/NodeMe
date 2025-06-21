import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:node_me/resources/friend_service.dart';

class HangoutRequestsScreen extends StatefulWidget {
  const HangoutRequestsScreen({super.key});

  @override
  State<HangoutRequestsScreen> createState() => _HangoutRequestsScreenState();
}

class _HangoutRequestsScreenState extends State<HangoutRequestsScreen> {
  late Future<List<Map<String, dynamic>>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _requestsFuture = FriendService().getHangouts(uid);
    }
  }

  Future<void> _acceptRequest(String requestId) async {
    final dbRef = FirebaseDatabase.instance.ref();
    await dbRef.child('hangout_requests/$requestId/status').set('accepted');
    setState(() {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        _requestsFuture = FriendService().getHangouts(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hangout Requests")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return const Center(child: Text("No pending requests."));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return ListTile(
                leading: const Icon(Icons.message),
                title: Text("Message: ${request['message']}"),
                subtitle: Text("From: ${request['senderUid']}"),
                trailing: ElevatedButton(
                  onPressed: () => _acceptRequest(request['requestId']),
                  child: const Text("Accept"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
