import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/custom_button.dart';
import '../models/chat_data.dart';

class ChatRequestItem extends StatelessWidget {
  final ChatData chatData;
  final VoidCallback? onTap;
  final bool isPlusSubscription;
  final DateTime? archiveEndTime;
  final bool thisArhive;
  final VoidCallback? onTimeExpired;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const ChatRequestItem({
    super.key,
    required this.chatData,
    this.onTap,
    this.isPlusSubscription = false,
    this.archiveEndTime,
    required this.thisArhive,
    this.onTimeExpired,
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 70;
    const Color highlightColor = Color.fromRGBO(0, 0, 0, 0.07);

    const TextStyle nameTextStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        highlightColor: highlightColor,
        splashColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Аватарка
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(avatarSize / 2),
                    child: Image.asset(
                      chatData.avatarUrl,
                      width: avatarSize,
                      height: avatarSize,
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Правая колонка с именем и кнопками
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chatData.name, style: nameTextStyle),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      CustomButton(
                        text: 'Принять',
                        onPressed: onAccept,
                        width: 100,
                        backgroundColor: Color.fromRGBO(146, 58, 174, 1),
                        textColor: Colors.white,
                        vert: 5,
                        horiz: 5,
                        height: 35,
                      ),
                      const SizedBox(width: 8),
                      CustomButton(
                        text: 'Отклонить',
                        onPressed: onDecline,
                        width: 100,
                        backgroundColor: Color.fromRGBO(155, 63, 184, 0.15),
                        textColor: Color.fromRGBO(146, 58, 174, 1),
                        vert: 5,
                        horiz: 5,
                        height: 35,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
