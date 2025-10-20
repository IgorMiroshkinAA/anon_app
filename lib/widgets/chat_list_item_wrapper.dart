import 'package:flutter/material.dart';

class ChatListItemWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onLongPress;

  const ChatListItemWrapper({Key? key, required this.child, this.onLongPress})
    : super(key: key);

  @override
  State<ChatListItemWrapper> createState() => _ChatListItemWrapperState();
}

class _ChatListItemWrapperState extends State<ChatListItemWrapper> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onLongPress: widget.onLongPress,
        child: Container(
          // Чтобы фон выделения занимал всю ширину с учётом паддингов родителя,
          // делаем ширину неявно расширяемой:
          width: double.infinity,
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.black.withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: widget.child,
        ),
      ),
    );
  }
}
