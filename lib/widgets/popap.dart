import 'package:flutter/material.dart';
import 'custom_button.dart';

class TextWithTwoButtons extends StatelessWidget {
  final String text;
  final VoidCallback onPrimaryPressed;
  final String primaryButtonText;
  final VoidCallback onSecondaryPressed;
  final String secondaryButtonText;

  const TextWithTwoButtons({
    super.key,
    required this.text,
    required this.onPrimaryPressed,
    required this.primaryButtonText,
    required this.onSecondaryPressed,
    required this.secondaryButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFCCE2CD), Color(0xFFFFFFFF), Color(0xFFD1C5ED)],
          stops: [0.0, 0.41, 1.2],
          transform: GradientRotation(180.13 * 3.1415927 / 180),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
            softWrap: true,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: primaryButtonText,
            onPressed: onPrimaryPressed,
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: secondaryButtonText,
            onPressed: onSecondaryPressed,
            width: double.infinity,
            backgroundColor: Colors.grey.shade400,
            textColor: Colors.black87,
          ),
        ],
      ),
    );
  }
}
