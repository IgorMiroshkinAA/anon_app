import 'package:flutter/material.dart';
import 'custom_button.dart';

class ConfirmDialogWidget extends StatelessWidget {
  final String content;
  final String? additionalText;
  final String confirmButtonText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmDialogWidget({
    Key? key,

    required this.content,
    this.additionalText,
    required this.confirmButtonText,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD1C5ED), Color(0xFFFFFFFF), Color(0xFFCCE2CD)],
          stops: [0, 0.4115, 1.2],
          transform: GradientRotation(180.13 * 3.1415927 / 180),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          ),
          if (additionalText != null && additionalText!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              additionalText!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 20),
          CustomButton(
            width: double.infinity,
            text: confirmButtonText,
            onPressed: onConfirm,
          ),
          const SizedBox(height: 6),
          CustomButton(
            width: double.infinity,
            text: "Отмена",
            onPressed: onCancel,
            backgroundColor: const Color.fromRGBO(0, 0, 0, 0.1),
            textColor: Colors.black,
            elevation: 0,
          ),
        ],
      ),
    );
  }
}
