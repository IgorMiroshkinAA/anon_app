// services/chat_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  IO.Socket? _socket;

  // Колбэки для обработки событий
  Function(int chatId, Map<String, dynamic> message)? onMessageReceived;
  Function(int chatId)? onChatEnded;
  Function(int chatId)? onChatArchived;

  // Подключиться к Socket.IO серверу
  void connect(String token, int userId) {
    try {
      print('🔄 Connecting to Socket.IO server...');
      print('📡 URL: http://89.109.34.227:3000');
      print('👤 User ID: $userId');

      _socket = IO.io(
        'http://89.109.34.227:3000',
        IO.OptionBuilder()
            .setQuery({'userId': userId.toString()})
            .setPath('/socket.io') // Явно указываем путь
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .build(),
      );

      // Обработчики событий
      _socket!.onConnect((_) {
        print('✅ Socket.IO connected successfully');
        print('🔌 Socket ID: ${_socket!.id}');
      });

      _socket!.onDisconnect((_) {
        print('❌ Socket.IO disconnected');
      });

      _socket!.onError((error) {
        print('💥 Socket.IO error: $error');
      });

      _socket!.onConnectError((error) {
        print('🚫 Socket.IO connect error: $error');
      });

      // Обработка входящих сообщений
      _socket!.on('newMessage', (data) {
        print('📨 Received new message: $data');
        if (onMessageReceived != null && data != null) {
          _handleIncomingMessage(data);
        }
      });

      // _socket!.on('chatEnded', (data) {
      //   print('🔚 Chat ended: $data');
      //   if (onChatEnded != null && data is Map) {
      //     final chatId = _parseChatId(data);
      //     if (chatId != null) onChatEnded!(chatId);
      //   }
      // });

      // _socket!.on('chatArchivedDueToInactivity', (data) {
      //   print('📦 Chat archived: $data');
      //   if (onChatArchived != null && data is Map) {
      //     final chatId = _parseChatId(data);
      //     if (chatId != null) onChatArchived!(chatId);
      //   }
      // });

      // Подключаемся
      _socket!.connect();
    } catch (e) {
      print('💀 Socket.IO connection error: $e');
    }
  }

  // Обработка входящих сообщений с преобразованием типов
  void _handleIncomingMessage(dynamic data) {
    try {
      print('🔄 Processing incoming message: $data');

      if (data is! Map) {
        print('❌ Invalid message format: $data');
        return;
      }

      // Преобразуем Map<dynamic, dynamic> в Map<String, dynamic>
      final messageData = <String, dynamic>{};
      data.forEach((key, value) {
        messageData[key.toString()] = value;
      });

      print('📝 Parsed message data: $messageData');

      final chatId = _parseChatId(messageData);
      if (chatId != null && onMessageReceived != null) {
        print('✅ Dispatching message to chat $chatId');
        onMessageReceived!(chatId, messageData);
      } else {
        print('❌ Could not parse chatId from: $messageData');
      }
    } catch (e) {
      print('💀 Error handling incoming message: $e');
    }
  }

  // Парсинг chatId из данных
  int? _parseChatId(Map<String, dynamic> data) {
    try {
      final chatId = data['chatId'];
      print('🔍 Parsing chatId: $chatId (type: ${chatId.runtimeType})');

      if (chatId is int) return chatId;
      if (chatId is String) return int.tryParse(chatId);
      if (chatId is double) return chatId.toInt();
      return null;
    } catch (e) {
      print('💀 Error parsing chatId: $e');
      return null;
    }
  }

  // Присоединиться к конкретному чату
  void joinChat(int chatId) {
    print('🚀 Joining chat: $chatId');
    _socket?.emit(
      'joinChat',
      chatId,
    ); // Отправляем просто число как в вашем HTML
  }

  // Отправить сообщение
  void sendMessage(int chatId, String text) {
    if (text.trim().isNotEmpty) {
      final messageData = {'chatId': chatId, 'text': text.trim()};
      print('📤 Sending message: $messageData');
      _socket?.emit('sendMessage', messageData);
    }
  }

  // Завершить чат
  void endChat(int chatId) {
    print('🛑 Ending chat: $chatId');
    _socket?.emit(
      'endChat',
      chatId,
    ); // Отправляем просто число как в вашем HTML
  }

  void disconnect() {
    print('👋 Disconnecting Socket.IO');
    _socket?.disconnect();
    _socket?.clearListeners();
  }

  // Проверить статус подключения
  bool get isConnected => _socket?.connected ?? false;

  // Получить ID сокета для отладки
  String? get socketId => _socket?.id;
}
