import 'package:flutter/material.dart';

typedef ConfirmCallback = void Function(String action);

class ChatActionButtons extends StatelessWidget {
  final VoidCallback onReportPressed;
  final ConfirmCallback onConfirmAction;
  final bool isArchiveContext;

  const ChatActionButtons({
    super.key,
    required this.onReportPressed,
    required this.onConfirmAction,
    this.isArchiveContext = false,
  });

  Widget buildButton({
    required VoidCallback onPressed,
    String? img,
    IconData? icon,
    required String label,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.grey[300],
        foregroundColor: foregroundColor ?? Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        minimumSize: const Size(60, 72),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (img != null)
            Image.asset(img, height: 25, width: 25)
          else if (icon != null)
            Icon(icon, size: 25),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.done_all, color: Colors.purple),
          const SizedBox(width: 10),
          buildButton(
            onPressed: () => onConfirmAction('В архив'),
            icon: Icons.inventory,
            label: 'В архив',
            foregroundColor: Color.fromRGBO(0, 0, 0, 0.3),
          ),
          const SizedBox(width: 3),
          buildButton(
            onPressed: () => onConfirmAction('Удалить'),
            img: 'assets/images/trash.png',
            label: 'Удалить',
            foregroundColor: Color.fromRGBO(0, 0, 0, 0.3),
          ),
          const SizedBox(width: 3),
          buildButton(
            onPressed: onReportPressed,
            icon: Icons.report_problem_rounded,
            label: 'Жалоба',
            backgroundColor: Colors.red,
            foregroundColor: Color.fromRGBO(255, 255, 255, 0.8),
          ),
        ],
      ),
    );
  }
}
