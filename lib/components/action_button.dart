import 'package:flutter/material.dart';
import 'package:nav_monitor/constants/fonts.dart';
//Beautifull blue button with white text

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ActionButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: buttonText,
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50), // Full width button
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        backgroundColor: Colors.blue, // Use your desired color
      ),
    );
  }
}
