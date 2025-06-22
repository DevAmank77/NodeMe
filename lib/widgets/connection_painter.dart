import 'package:flutter/material.dart';

class ConnectionPainter extends CustomPainter {
  final List nodes;

  ConnectionPainter(this.nodes);

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
