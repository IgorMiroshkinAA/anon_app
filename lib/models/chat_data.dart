class ChatData {
  final String avatarUrl;
  final String name;
  final int userId;
  final bool isRead;
  final bool isOnline;
  final bool isRepeatRequest;
  final DateTime? archiveStartTime;

  // Сделаем необязательными — может не быть сообщений
  final String? lastMessage;
  final String? lastMessageTime;
  final String? timerLabel;
  final int? newMessagesCount;

  const ChatData({
    required this.userId,
    required this.avatarUrl,
    required this.name,
    required this.isRead,
    this.isOnline = false,
    required this.isRepeatRequest,
    this.archiveStartTime,
    this.lastMessage,
    this.lastMessageTime,
    this.timerLabel,
    this.newMessagesCount,
  });
}
