import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendGraphScreen extends StatefulWidget {
  const FriendGraphScreen({super.key});

  @override
  State<FriendGraphScreen> createState() => _FriendGraphScreenState();
}

class _FriendGraphScreenState extends State<FriendGraphScreen> {
  Map<String, List<String>> graph = {};
  Map<String, String> uidToName = {}; // Mapping UID -> Name
  String? expandedNode;
  String centerUser = FirebaseAuth.instance.currentUser?.uid ?? "Me";

  @override
  void initState() {
    super.initState();
    fetchGraphFromFirebase();
  }

  Future<void> fetchGraphFromFirebase() async {
    final dbRef = FirebaseDatabase.instance.ref();
    final firestore = FirebaseFirestore.instance;
    final snapshot = await dbRef.child('users').get();

    final Map<String, List<String>> tempGraph = {};
    final Map<String, String> tempNameMap = {};

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final userIds = data.keys.toList();

      for (var entry in data.entries) {
        final uid = entry.key;
        final userData = Map<String, dynamic>.from(entry.value);
        final friendsMap = Map<String, dynamic>.from(
          userData['firstDegreeIds'] ?? {},
        );
        final friendsList = friendsMap.keys.toList();
        tempGraph[uid] = List<String>.from(friendsList);
      }

      // Fetch user names from Firestore
      final userDocs = await firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: userIds)
          .get();
      for (var doc in userDocs.docs) {
        final uid = doc.id;
        final name = doc.data()['name'] ?? uid;
        tempNameMap[uid] = name;
      }
    }

    setState(() {
      graph = tempGraph;
      uidToName = tempNameMap;
    });
  }

  void toggleNode(String name) {
    setState(() {
      if (expandedNode == name) {
        expandedNode = null;
      } else {
        expandedNode = name;
      }
    });
  }

  List<_NodeData> getAllNodes() {
    List<_NodeData> allNodes = [];

    final center = const Offset(180, 400);
    allNodes.add(_NodeData(name: centerUser, position: center));

    final firstDegree = graph[centerUser] ?? [];
    const radius = 120.0;

    for (int i = 0; i < firstDegree.length; i++) {
      final angle = 2 * pi * i / firstDegree.length;
      Offset pos;
      final nodeUid = firstDegree[i];

      if (expandedNode == nodeUid) {
        pos = const Offset(180, 100);
      } else {
        final dx = center.dx + radius * cos(angle);
        final dy = center.dy + radius * sin(angle);
        pos = Offset(dx, dy);
      }

      allNodes.add(_NodeData(name: nodeUid, position: pos, parent: centerUser));

      if (expandedNode == nodeUid) {
        final children = (graph[nodeUid] ?? [])
            .where((id) => id != centerUser)
            .toList();
        for (int j = 0; j < children.length; j++) {
          final subAngle = 2 * pi * j / children.length;
          final subDx = pos.dx + 70 * cos(subAngle);
          final subDy = pos.dy + 70 * sin(subAngle);
          final subPos = Offset(subDx, subDy);
          allNodes.add(
            _NodeData(name: children[j], position: subPos, parent: nodeUid),
          );
        }
      }
    }

    return allNodes;
  }

  void _showUserOptionsPopup(String uid) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('View Profile'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to profile screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text('Add to Hangout'),
            onTap: () {
              Navigator.pop(context);
              _showCreateHangoutDialog(uid);
            },
          ),
        ],
      ),
    );
  }

  void _showCreateHangoutDialog(String friendUid) {
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Send Hangout Request"),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(labelText: "Personalized message"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final message = messageController.text;
              await _sendHangoutRequest(friendUid, message);
              Navigator.pop(context);
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  Future<void> _sendHangoutRequest(String friendUid, String message) async {
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

  @override
  Widget build(BuildContext context) {
    final nodes = getAllNodes();

    return Scaffold(
      appBar: AppBar(title: const Text("Friend Graph")),
      body: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: _ConnectionPainter(nodes)),
          ...nodes.map(
            (node) => Positioned(
              left: node.position.dx - 25,
              top: node.position.dy - 25,
              child: GestureDetector(
                onTap: () {
                  if (node.name != centerUser && graph.containsKey(node.name)) {
                    toggleNode(node.name);
                  }
                },
                onLongPress: () => _showUserOptionsPopup(node.name),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: expandedNode == node.name
                          ? Colors.blueAccent
                          : Colors.grey[300],
                      child: Text((uidToName[node.name] ?? node.name)[0]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      uidToName[node.name] ?? node.name,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NodeData {
  final String name;
  final Offset position;
  final String? parent;

  _NodeData({required this.name, required this.position, this.parent});
}

class _ConnectionPainter extends CustomPainter {
  final List<_NodeData> nodes;

  _ConnectionPainter(this.nodes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    for (var node in nodes) {
      if (node.parent != null) {
        final parentNode = nodes.firstWhere((n) => n.name == node.parent);
        canvas.drawLine(parentNode.position, node.position, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
