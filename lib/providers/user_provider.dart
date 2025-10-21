import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_application/services/chat_service.dart';
import '../models/user_registration.dart';
import '../services/auth_service.dart';
import '../models/chat_data.dart';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  final UserRegistration _user = UserRegistration(id: 0);
  String? _tempToken;
  String? _finalToken;
  final ChatService _chatService = ChatService();
  static const String baseUrl = 'http://10.0.2.2:4000/api';

  // Добавляем списки чатов
  List<ChatData> _activeChats = [];
  List<ChatData> _archiveChats = [];
  List<ChatData> _requestChats = [];

  List<ChatData> get activeChats => _activeChats;
  List<ChatData> get archiveChats => _archiveChats;
  List<ChatData> get requestChats => _requestChats;

  UserRegistration get user => _user;
  String? get finalToken => _finalToken;

  // Запросить код на email
  Future<void> requestCode(String email) async {
    _tempToken = await AuthService.requestCode(email);
    _user.email = email;
    notifyListeners();
  }

  // Запросить повторно код на email (Вышло время)
  Future<void> resendCode(String email) async {
    _tempToken = await AuthService.resendCode(email);
    _user.email = email;
    notifyListeners();
  }

  // Проверить код
  Future<void> verifyCode(String code) async {
    if (_tempToken == null) throw Exception('Token отсутствует');
    _finalToken = await AuthService.verifyCode(_tempToken!, code); // ✅ accessToken
  }


  // Установить никнейм, получить финальный токен
  Future<void> setNickname(String nickname) async {
    if (_finalToken == null) throw Exception('AccessToken отсутствует');
    _finalToken = await AuthService.setNickname(_finalToken!, nickname); // ✅ правильный токен
    _user.name = nickname;
    notifyListeners();
  }

  // Установить возраст
  Future<void> setAge(int age) async {
    if (_finalToken == null) throw Exception('Финальный токен отсутсвует');
    await AuthService.setAge(_finalToken!, age);
    _user.age = age;
    notifyListeners();
  }

  // Установить пароль
  Future<void> setPassword(String password, String confirm) async {
    if (_finalToken == null) throw Exception('Финальный токен отсутствует');
    _finalToken = await AuthService.setPassword(
      _finalToken!,
      password,
      confirm,
    );
    _user.password = password;
    notifyListeners();
  }


  Future<void> _loadChats() async {
    if (_finalToken == null) throw Exception('Финальный токен отсутствует');

    try {
      // Загружаем активные чаты
      final activeChatsData = await AuthService.getActiveChats(_finalToken!);
      _activeChats = _parseChatsFromData(activeChatsData);

      final archiveChats = await AuthService.getArchiveChats(_finalToken!);
      _archiveChats = _parseChatsFromData(archiveChats);

      // Здесь можно добавить загрузку архивных чатов и запросов
      // _archiveChats = await AuthService.getArchiveChats(_finalToken!);
      // _requestChats = await AuthService.getRequestChats(_finalToken!);

      notifyListeners();
    } catch (e) {
      print('Ошибка загрузки чатов: $e');
      throw e;
    }
  }

  // Парсинг данных чатов из API
  List<ChatData> _parseChatsFromData(List<dynamic> chatsData) {
    return chatsData.map((chatData) {
      final userId = chatData['user1Id'] == _user.id
          ? chatData['user2Id']
          : chatData['user1Id'];

      return ChatData(
        userId: userId,
        avatarUrl: chatData['avatarUrl'] ?? 'assets/images/accGray.png',
        name: chatData['name'] ?? 'Неизвестный',
        lastMessage: chatData['lastMessage'] ?? '',
        lastMessageTime: chatData['lastMessageTime'] ?? '',
        timerLabel: chatData['timerLabel'] ?? '',
        newMessagesCount: chatData['newMessagesCount'] ?? 0,
        isRead: chatData['isRead'] ?? false,
        isOnline: chatData['isOnline'] ?? false,
        isRepeatRequest: chatData['isRepeatRequest'] ?? false,
      );
    }).toList();
  }

  // Обновление списка чатов
  Future<void> refreshChats() async {
    await _loadChats();
  }

  // Добавление нового чата
  void addChat(
    ChatData chat, {
    bool isArchive = false,
    bool isRequest = false,
  }) {
    if (isRequest) {
      _requestChats.add(chat);
    } else if (isArchive) {
      _archiveChats.add(chat);
    } else {
      _activeChats.add(chat);
    }
    notifyListeners();
  }

  // Удаление чата
  void removeChat(
    int userId, {
    bool isArchive = false,
    bool isRequest = false,
  }) {
    if (isRequest) {
      _requestChats.removeWhere((chat) => chat.userId == userId);
    } else if (isArchive) {
      _archiveChats.removeWhere((chat) => chat.userId == userId);
    } else {
      _activeChats.removeWhere((chat) => chat.userId == userId);
    }
    notifyListeners();
  }

  // Перемещение чата в архив
  void moveToArchive(int userId) {
    final chat = _activeChats.firstWhere((chat) => chat.userId == userId);
    _activeChats.removeWhere((chat) => chat.userId == userId);
    _archiveChats.add(chat);
    notifyListeners();
  }

  // Восстановление чата из архива
  void restoreFromArchive(int userId) {
    final chat = _archiveChats.firstWhere((chat) => chat.userId == userId);
    _archiveChats.removeWhere((chat) => chat.userId == userId);
    _activeChats.add(chat);
    notifyListeners();
  }

  // Обновление информации о чате
  void updateChat(
    ChatData updatedChat, {
    bool isArchive = false,
    bool isRequest = false,
  }) {
    List<ChatData> targetList;

    if (isRequest) {
      targetList = _requestChats;
    } else if (isArchive) {
      targetList = _archiveChats;
    } else {
      targetList = _activeChats;
    }

    final index = targetList.indexWhere(
      (chat) => chat.userId == updatedChat.userId,
    );
    if (index != -1) {
      targetList[index] = updatedChat;
      notifyListeners();
    }
  }

  Future<void> selectPlan(int planId) async {
    if (_finalToken == null) throw Exception('Финальный токен отсутствует');

    try {
      await AuthService.selectPlan(_finalToken!, planId);
      _user.levelSubscription = planId;
      notifyListeners();
    } catch (e) {
      throw Exception('Ошибка при выборе тарифа: $e');
    }
  }

  int get activePlanId => _user.levelSubscription ?? 1;

  Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_finalToken',
        },
      );

      if (response.statusCode == 200) {

        // Очистка состояния
        _user.email = null;
        _user.name = null;
        _user.age = null;
        _user.password = null;
        _finalToken = null;
        _tempToken = null;

        _activeChats.clear();
        _archiveChats.clear();
        _requestChats.clear();

        notifyListeners();
      } else {
        throw Exception('Ошибка при выходе: ${response.body}');
      }
    } catch (e) {
      print('Logout error: $e');
      rethrow;
    }
  }

  Future<String?> login(String email, String password) async {
    if (email == "login") {
      email = _user.email!;
    }

    if (_tempToken == null) {
      throw Exception('Временный токен отсутствует. Сначала вызови initAuth(email)');
    }

    try {
      _finalToken = await AuthService.verifyPassword(_tempToken!, password);

      final userData = await AuthService.getUser(_finalToken!);
      final user = userData['user'];

      _user.id = int.tryParse(user['id'].toString()) ?? 0;
      _user.email = user['email'];
      _user.name = user['nickname'];
      _user.age = user['age'];

      _initializeChatService();

      try {
        await _loadChats();
      } catch (e) {
        print('Чаты не загружены: $e');
      }

      notifyListeners();
      return null;
    } catch (e) {
      throw Exception('Неверный пароль или токен');
    }
  }

  void _initializeChatService() {
    if (_finalToken != null && _user.id! > 0) {
      _chatService.connect(_finalToken!, _user.id!);

      // Устанавливаем обработчики событий
      _chatService.onMessageReceived = _handleNewMessage;
      _chatService.onChatEnded = _handleChatEnded;
      _chatService.onChatArchived = _handleChatArchived;
    }
  }

  void _handleNewMessage(int chatId, Map<String, dynamic> messageData) {
    // Обновляем UI при получении нового сообщения
    print('New message in chat $chatId: ${messageData['text']}');

    // Можно обновить конкретный чат или просто обновить все чаты
    _loadChats(); // или более точечное обновление
    notifyListeners();
  }

  void _handleChatEnded(int chatId) {
    // Обработка завершения чата
    print('Chat $chatId ended');
    // Обновляем список чатов
    _loadChats();
    notifyListeners();
  }

  void _handleChatArchived(int chatId) {
    // Обработка архивации чата по бездействию
    print('Chat $chatId archived due to inactivity');
    _loadChats();
    notifyListeners();
  }

  // Присоединиться к чату (вызывается при открытии экрана чата)
  void joinChat(int chatId) {
    print('🔗 UserProvider: Joining chat $chatId');
    _chatService.joinChat(chatId);
  }

  // Отправить сообщение
  void sendMessage(int chatId, String text) {
    print('💬 UserProvider: Sending message to chat $chatId: "$text"');
    _chatService.sendMessage(chatId, text);
  }

  // Завершить чат
  void endChat(int chatId) {
    _chatService.endChat(chatId);
  }

  // Получить экземпляр ChatService для доступа из других экранов
  ChatService get chatService => _chatService;

  @override
  void dispose() {
    _chatService.disconnect();
    super.dispose();
  }

  Future<String> initAuth(String email) async {
    final response = await AuthService.initAuth(email);
    final mode = response['mode']; // 'login' или 'registration'
    final token = response['token'];

    _tempToken = token;
    _user.email = email;

    print('📧 initAuth: $email → $mode');

    notifyListeners();
    return mode;
  }

}
