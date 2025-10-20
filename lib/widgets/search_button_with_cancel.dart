import 'package:flutter/material.dart';

class SearchButtonWithCancel extends StatelessWidget {
  final bool isSearching;
  final bool isConversationsOver;
  final int availableConversations;
  final VoidCallback onSearchPressed;
  final VoidCallback onCancelPressed;
  final int searchSeconds;

  const SearchButtonWithCancel({
    Key? key,
    required this.isSearching,
    required this.isConversationsOver,
    required this.availableConversations,
    required this.onSearchPressed,
    required this.onCancelPressed,
    required this.searchSeconds,
  }) : super(key: key);

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    final minsStr = mins.toString().padLeft(2, '0');
    final secsStr = secs.toString().padLeft(2, '0');
    return '$minsStr:$secsStr';
  }

  @override
  Widget build(BuildContext context) {
    final text = isConversationsOver
        ? 'Беседы закончились'
        : isSearching
        ? 'Ищем...  '
        : 'Поиск собеседника';

    Color textColor;
    if (isConversationsOver) {
      textColor = const Color.fromRGBO(0, 0, 0, 0.4);
    } else if (isSearching) {
      textColor = const Color.fromRGBO(0, 0, 0, 1);
    } else {
      textColor = Colors.white;
    }

    final backgroundColor = isConversationsOver
        ? Colors.grey.shade400
        : (isSearching
              ? Colors.grey.shade600
              : const Color.fromARGB(51, 51, 51, 1));

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: isConversationsOver || isSearching ? null : onSearchPressed,
      child: SizedBox(
        width: 220,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Текст и секундомер по центру
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSearching)
                  // Текст "Ищем..." и секундомер строго по центру
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          text,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(searchSeconds),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
            // Иконка закрытия, если идет поиск, слева
            if (isSearching)
              Positioned(
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: onCancelPressed,
                  tooltip: 'Остановить поиск',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  splashRadius: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
