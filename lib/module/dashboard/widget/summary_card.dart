import 'package:flutter/material.dart';
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final Color textColor;
  const SummaryCard(
      {super.key,
      required this.title,
      required this.value,
      required this.color,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: textColor)),
        ],
      ),
    );
  }
}