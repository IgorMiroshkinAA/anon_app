// models/message.dart
class Message {
  final int? id;
  final String text;
  final bool isSentByMe;
  final DateTime timestamp;
  final bool isRead;
  final int? chatId;
  final int? senderId;

  Message({
    this.id,
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
    this.isRead = false,
    this.chatId,
    this.senderId,
  });

  factory Message.fromJson(Map<String, dynamic> json, int currentUserId) {
    return Message(
      id: json['id'],
      text: json['content'] ?? json['text'],
      isSentByMe: json['senderId'] == currentUserId,
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      chatId: json['chatId'],
      senderId: json['senderId'],
    );
  }

  // Метод для создания сообщения из WebSocket данных
  factory Message.fromWebSocketData(
    Map<String, dynamic> data,
    int currentUserId,
  ) {
    return Message(
      text: data['text'],
      isSentByMe: data['senderId'] == currentUserId,
      timestamp: DateTime.parse(data['timestamp']),
      senderId: data['senderId'],
      chatId: data['chatId'],
    );
  }
}
