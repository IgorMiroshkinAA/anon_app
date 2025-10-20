import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/chat_timer.dart';

import '../models/chat_data.dart';

class ChatItem extends StatelessWidget {
  final ChatData chatData;
  final void Function()? onTap;
  final bool isPlusSubscription;
  final DateTime? archiveEndTime;
  final bool thisArhive;
  final VoidCallback? onTimeExpired;

  const ChatItem({
    Key? key,
    required this.chatData,
    this.onTap,
    this.isPlusSubscription = false,
    this.archiveEndTime,
    required this.thisArhive,
    this.onTimeExpired,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 56;
    // const double timerIconSize = 16;
    // const Color timerBgColor = Color.fromRGBO(0, 0, 0, 0.1);
    const Color timerIconColor = Color.fromRGBO(138, 137, 138, 1);
    const Color highlightColor = Color.fromRGBO(0, 0, 0, 0.07);
    const TextStyle nameTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    );
    const TextStyle timerTextStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: timerIconColor,
    );
    final TextStyle lastMessageStyle = TextStyle(
      fontSize: 14,
      color: Colors.black.withOpacity(0.6),
    );
    final TextStyle messageTimeStyle = TextStyle(
      fontSize: 12,
      color: Colors.black.withOpacity(0.4),
    );

    // Иконки для таймера
    const IconData activeTabTimerIcon = Icons.timer; // иконка для «Активных»
    const IconData archiveTabTimerIcon = Icons.inventory; // иконка для «Архива»

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        highlightColor: highlightColor,
        splashColor: Colors.transparent,
        child: SizedBox(
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  // Индикатор онлайн
                  if (chatData.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 1,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(146, 58, 174, 1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Первая строка: имя + timer
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            chatData.name,
                            style: nameTextStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (chatData.lastMessage!.isNotEmpty &&
                            chatData.lastMessageTime!.isNotEmpty)
                          ChatTimer(
                            isPlusSubscription: isPlusSubscription,
                            endTime: archiveEndTime,
                            timerIcon: thisArhive
                                ? archiveTabTimerIcon
                                : activeTabTimerIcon,
                            staticLabel: chatData.timerLabel,
                            onTimeExpired: onTimeExpired,
                          ),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //     horizontal: 6,
                        //     vertical: 2,
                        //   ),
                        //   decoration: BoxDecoration(
                        //     color: timerBgColor,
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //   child: Row(
                        //     children: [
                        //       Icon(
                        //         Icons.timer,
                        //         size: timerIconSize,
                        //         color: timerIconColor,
                        //       ),
                        //       const SizedBox(width: 4),
                        //       Text(chatData.timerLabel, style: timerTextStyle),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 1),

                    // Вторая строка: сокращенный текст + точка + время сообщения
                    if (chatData.lastMessage!.isNotEmpty &&
                        chatData.lastMessageTime!.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              chatData.lastMessage ?? "",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: lastMessageStyle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            chatData.lastMessageTime ?? "",
                            style: messageTimeStyle,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Правая иконка: бейдж с кол-вом новых сообщений или галочка
              if (chatData.lastMessage!.isNotEmpty)
                if (chatData.newMessagesCount! > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    child: Center(
                      child: Text(
                        '${chatData.newMessagesCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  Icon(
                    chatData.isRead ? Icons.done_all : Icons.check,
                    size: 24,
                    color: Color.fromRGBO(146, 58, 174, 1),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
