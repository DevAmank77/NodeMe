import 'package:flutter/material.dart';
import 'package:node_me/utils/app_color.dart';

class CustomSimpleRoundedButton extends StatelessWidget {
  final Color bgcolor;
  final VoidCallback onPressed;
  final String text;
  const CustomSimpleRoundedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.bgcolor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: bgcolor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
