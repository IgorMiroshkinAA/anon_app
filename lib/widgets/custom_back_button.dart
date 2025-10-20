import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool showColor;

  const CustomBackButton({super.key, this.onPressed, this.showColor = true});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: GestureDetector(
            onTap: onPressed ?? () => Navigator.of(context).pop(),
            child: Container(
              decoration: !showColor
                  ? null
                  : BoxDecoration(
                      color: Colors.black.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
              padding: EdgeInsets.only(right: 8, left: 7, top: 8, bottom: 8),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
