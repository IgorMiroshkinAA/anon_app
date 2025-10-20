import 'dart:async';
import 'package:flutter/material.dart';

class ChatTimer extends StatefulWidget {
  final DateTime? endTime;
  final bool isPlusSubscription;
  final String? staticLabel;
  final IconData timerIcon;
  final VoidCallback? onTimeExpired;

  const ChatTimer({
    Key? key,
    this.endTime,
    this.isPlusSubscription = false,
    this.staticLabel,
    required this.timerIcon,
    this.onTimeExpired,
  }) : super(key: key);

  @override
  _ChatTimerState createState() => _ChatTimerState();
}

class _ChatTimerState extends State<ChatTimer> {
  Timer? _timer;
  Duration? _remaining;

  @override
  void initState() {
    super.initState();
    if (widget.isPlusSubscription && widget.endTime != null) {
      _updateRemaining();
      _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateRemaining());
    }
  }

  void _updateRemaining() {
    final endTime = widget.endTime;
    if (endTime == null) return;

    final now = DateTime.now();
    final remaining = endTime.difference(now);

    if (remaining.isNegative || remaining == Duration.zero) {
      _timer?.cancel();
      setState(() {
        _remaining = Duration.zero;
      });
      if (widget.onTimeExpired != null) {
        widget.onTimeExpired!();
      }
      return;
    }

    setState(() {
      _remaining = remaining;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Для пользователей без подписки Plus показываем либо статический лейбл, либо ничего
    if (!widget.isPlusSubscription) {
      if (widget.staticLabel != null) {
        return TimerLabel(text: widget.staticLabel!, icon: widget.timerIcon);
      } else {
        return const SizedBox.shrink();
      }
    }
    final remaining = _remaining;
    if (remaining == null || remaining == Duration.zero) {
      // Время вышло — не показываем таймер (чат будет удалён родителем)
      return const SizedBox.shrink();
    }

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    return TimerLabel(
      text: '${hours}ч ${minutes.toString().padLeft(2, '0')}м',
      icon: widget.timerIcon,
    );
  }
}

class TimerLabel extends StatelessWidget {
  final String text;
  final IconData icon;

  const TimerLabel({Key? key, required this.text, required this.icon})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    const timerBgColor = Color.fromRGBO(0, 0, 0, 0.1);
    const timerIconColor = Color.fromRGBO(138, 137, 138, 1);
    // const double timerIconSize = 16;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: timerBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: timerIconColor),
          // Icon(Icons.timer, size: timerIconSize, color: timerIconColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: timerIconColor,
            ),
          ),
        ],
      ),
    );
  }
}
