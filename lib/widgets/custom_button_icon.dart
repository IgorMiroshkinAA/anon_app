import 'package:flutter/material.dart';

class IconTextButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback onPressed;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? width;

  const IconTextButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isEnabled = true,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          shadowColor: Colors.transparent,
          backgroundColor: isEnabled
              ? (backgroundColor ?? Color.fromRGBO(0, 0, 0, 0.1))
              : Color.fromRGBO(0, 0, 0, 0.1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: textColor ?? Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                fontFamily: 'Rounded',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
