import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/custom_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String text;
  final String img;
  final VoidCallback onGoToMainTab;

  const EmptyStateWidget({
    Key? key,
    required this.message,
    required this.onGoToMainTab,
    required this.text,
    required this.img,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(img),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color.fromARGB(214, 99, 98, 98),
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 50, vertical: 8),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color.fromARGB(188, 99, 98, 98),
              ),
            ),
          ),

          CustomButton(text: 'Перейти к поиску', onPressed: onGoToMainTab),
        ],
      ),
    );
  }
}
