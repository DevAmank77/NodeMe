import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:node_me/models/node_data.dart';
import 'package:node_me/resources/firebase_graph_service.dart';
import 'package:node_me/resources/hangout_service.dart';
import 'package:node_me/widgets/connection_painter.dart';
import 'package:node_me/widgets/user_popup.dart';

class FriendGraphScreen extends StatefulWidget {
  const FriendGraphScreen({super.key});

  @override
  State<FriendGraphScreen> createState() => _FriendGraphScreenState();
}

class _FriendGraphScreenState extends State<FriendGraphScreen> {
  Map<String, List<String>> graph = {};
  Map<String, String> uidToName = {};
  String? expandedNode;
  String centerUser = FirebaseAuth.instance.currentUser?.uid ?? "Me";

  @override
  void initState() {
    super.initState();
    fetchGraph();
  }

  Future<void> fetchGraph() async {
    final tempGraph = await FirebaseGraphService.fetchFriendGraph();
    final allUids = tempGraph.keys
        .toSet()
        .union(tempGraph.values.expand((e) => e).toSet())
        .toList();
    final tempNameMap = await FirebaseGraphService.fetchUserNames(allUids);

    setState(() {
      graph = tempGraph;
      uidToName = tempNameMap;
    });
  }

  void toggleNode(String name) {
    setState(() {
      expandedNode = expandedNode == name ? null : name;
    });
  }

  void showHangoutDialog(String uid) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Send Hangout Request"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Personalized message"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseGraphService.sendHangoutRequest(
                uid,
                controller.text,
              );
              Navigator.pop(context);
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  List<NodeData> getAllNodes() {
    final center = const Offset(180, 400);
    List<NodeData> nodes = [NodeData(name: centerUser, position: center)];
    final firstDegree = graph[centerUser] ?? [];
    const radius = 120.0;

    for (int i = 0; i < firstDegree.length; i++) {
      final angle = 2 * pi * i / firstDegree.length;
      final dx = center.dx + radius * cos(angle);
      final dy = center.dy + radius * sin(angle);
      final nodeUid = firstDegree[i];
      final nodePos = (expandedNode == nodeUid)
          ? const Offset(180, 100)
          : Offset(dx, dy);

      nodes.add(NodeData(name: nodeUid, position: nodePos, parent: centerUser));

      if (expandedNode == nodeUid) {
        final children = (graph[nodeUid] ?? [])
            .where((c) => c != centerUser)
            .toList();
        for (int j = 0; j < children.length; j++) {
          final subAngle = 2 * pi * j / children.length;
          final subDx = nodePos.dx + 70 * cos(subAngle);
          final subDy = nodePos.dy + 70 * sin(subAngle);
          nodes.add(
            NodeData(
              name: children[j],
              position: Offset(subDx, subDy),
              parent: nodeUid,
            ),
          );
        }
      }
    }
    return nodes;
  }

  @override
  Widget build(BuildContext context) {
    final nodes = getAllNodes();

    return Scaffold(
      appBar: AppBar(title: const Text("Friend Graph")),
      body: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: ConnectionPainter(nodes)),
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
                onLongPress: () {
                  showUserOptionsPopup(
                    context,
                    centerUser,
                    node.name,
                    () => showUserOptionsPopup,
                    (hangoutId) => HangoutService().requestAddMember(
                      context: context,
                      hangoutId: hangoutId,
                      receiverId: node.name,
                    ),
                  );
                },
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
