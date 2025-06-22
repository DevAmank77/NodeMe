import 'dart:ui';

class NodeData {
  final String name;
  final Offset position;
  final String? parent;

  NodeData({required this.name, required this.position, this.parent});
}
