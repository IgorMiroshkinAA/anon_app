import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final Widget? icon;
  final int? elevation;
  final double? vert;
  final double? height;
  final double? horiz;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isEnabled = true,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.icon,
    this.elevation,
    this.vert,
    this.height,
    this.horiz,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 280,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? (backgroundColor ?? const Color.fromRGBO(51, 51, 51, 1))
              : Color.fromRGBO(0, 0, 0, 0.2),

          foregroundColor: textColor ?? Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: horiz ?? 0,
            vertical: vert?.toDouble() ?? 12.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Rounded',
          ),
          // shadowColor: const Color(0xFF511765),
          elevation: 0,
        ),
        child: Text(text),
      ),
    );
  }
}
