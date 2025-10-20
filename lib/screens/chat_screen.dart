import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/widgets/complain_widget.dart';
import 'package:flutter_application/widgets/confirm_dialog_widget.dart';
import 'package:flutter_application/widgets/custom_back_button.dart';
import 'package:flutter_application/widgets/custom_button.dart';
import 'package:flutter_application/widgets/feedback_widget.dart';
import '../models/chat_data.dart';
import '../providers/user_provider.dart';

class Message {
  final String text;
  final bool isSentByMe;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
    this.isRead = false,
  });
}

class ChatScreen extends StatefulWidget {
  final ChatData user;
  final void Function(ChatData user, bool isArchive)? deleteUser;
  final void Function(ChatData user)? addArchive;
  final bool isArchive;

  const ChatScreen({
    Key? key,
    required this.user,
    this.deleteUser,
    this.isArchive = false,
    this.addArchive,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int? _selectedMessageIndex;
  bool _isRequestSent = false;
  List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final Map<int, Rect> _messageRects = {};

  UserProvider? _userProvider;
  late int _currentUserId;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userProvider = Provider.of<UserProvider>(context, listen: false);
      _currentUserId = _userProvider!.user.id!;

      // Присоединяемся к чату через WebSocket
      _userProvider!.joinChat(widget.user.userId);

      // Подписываемся на получение сообщений
      _userProvider!.chatService.onMessageReceived = _handleNewMessage;

      _loadMessages();
    });
  }

  void _loadMessages() async {
    try {
      // TODO: Загрузить историю сообщений из API
      // final messagesData = await AuthService.getChatMessages(widget.user.userId);
      // setState(() {
      //   _messages = _parseMessages(messagesData);
      // });

      // Временные данные для демонстрации
      setState(() {
        _messages = [
          Message(
            text: "Привет! Как дела?",
            isSentByMe: false,
            timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          ),
          Message(
            text: "Привет! Всё отлично, спасибо. А у тебя?",
            isSentByMe: true,
            timestamp: DateTime.now().subtract(
              const Duration(minutes: 9, seconds: 30),
            ),
            isRead: true,
          ),
        ];
      });
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Отправка через WebSocket
    _userProvider?.sendMessage(widget.user.userId, text);

    // Локально добавляем сообщение для мгновенного отображения
    setState(() {
      _messages.add(
        Message(
          text: text,
          isSentByMe: true,
          timestamp: DateTime.now(),
          isRead: false,
        ),
      );
    });

    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Обработка новых сообщений из WebSocket
  void _handleNewMessage(int chatId, Map<String, dynamic> messageData) {
    // Проверяем, что сообщение для этого чата
    if (messageData['chatId'] == widget.user.userId && mounted) {
      final isSentByMe = messageData['senderId'] == _currentUserId;

      setState(() {
        _messages.add(
          Message(
            text: messageData['text'],
            isSentByMe: isSentByMe,
            timestamp: DateTime.parse(messageData['timestamp']),
            isRead: false,
          ),
        );
      });
      _scrollToBottom();
    }
  }

  void _onSelectMessage(int index, Rect rect) {
    setState(() {
      _selectedMessageIndex = index;
      _messageRects[index] = rect;
    });
  }

  void _showConfirmDialog({
    required String action,
    required bool isArchive,
    String? content,
    String? additionalText,
    String? confirmButtonText,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(left: 0, right: 0, bottom: 0),
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: MediaQuery.of(ctx).size.width,
              child: ConfirmDialogWidget(
                content: content ?? 'Вы уверены, что хотите $action этот чат?',
                additionalText: additionalText,
                confirmButtonText: confirmButtonText ?? action,
                onConfirm: () {
                  if (action == 'В архив') {
                    Future.delayed(Duration(milliseconds: 100), () {
                      _showFeedbackDialog(content);
                    });
                  } else if (action == 'Удалить') {
                    if (widget.deleteUser != null) {
                      widget.deleteUser!(widget.user, widget.isArchive);
                    }
                  }
                  Navigator.pop(ctx);
                },
                onCancel: () => Navigator.pop(ctx),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFeedbackDialog(content) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: MediaQuery.of(ctx).size.width,
                child: FeedbackWidget(
                  content: "Как прошла беседа?",
                  onConfirm: () {
                    if (widget.addArchive != null) {
                      widget.addArchive!(widget.user);
                    }
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showComplainDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: MediaQuery.of(ctx).size.width,
                child: ComplainWidget(
                  content: "Жалоба на собеседника?",
                  onConfirm: () {
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // Отписываемся от событий WebSocket
    if (_userProvider != null) {
      _userProvider!.chatService.onMessageReceived = null;
    }
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    const double avatarSize = 40;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(151, 207, 154, 0.0),
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF),
              Color.fromRGBO(169, 146, 224, 0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // AppBar area
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        const CustomBackButton(showColor: false),
                        const SizedBox(width: 10),
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                avatarSize / 2,
                              ),
                              child: Image.asset(
                                user.avatarUrl,
                                width: avatarSize,
                                height: avatarSize,
                                fit: BoxFit.cover,
                                opacity: const AlwaysStoppedAnimation(0.6),
                              ),
                            ),
                            if (user.isOnline)
                              Positioned(
                                bottom: -1,
                                right: -1,
                                child: Container(
                                  width: 13,
                                  height: 13,
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(
                                      146,
                                      58,
                                      174,
                                      1,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          offset: const Offset(0, 45),
                          icon: const Icon(
                            Icons.more_horiz,
                            color: Colors.black87,
                            size: 30,
                          ),
                          onSelected: (value) {
                            switch (value) {
                              case 'archive':
                                _showConfirmDialog(
                                  action: 'В архив',
                                  isArchive: widget.isArchive,
                                  content: 'Вы хотите закончить чат?',
                                  additionalText:
                                      'Законченные чаты перенесутся в архив',
                                  confirmButtonText: 'Закончить',
                                );
                                break;
                              case 'delete':
                                _showConfirmDialog(
                                  action: 'Удалить',
                                  isArchive: widget.isArchive,
                                  content:
                                      'Вы хотите удалить чат без возможности восстановления?',
                                  confirmButtonText: 'Удалить',
                                );
                                break;
                              case 'complain':
                                _showComplainDialog();
                                break;
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.white,
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              height: 34.0,
                              value: 'archive',
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'Архивировать',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(
                                    Icons.archive_rounded,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem(
                              height: 34.0,
                              value: 'delete',
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'Удалить чат',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(
                                    Icons.delete_rounded,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem(
                              height: 34.0,
                              value: 'complain',
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'Жалоба на собеседника',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(
                                    Icons.warning_rounded,
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Сообщения
                  Expanded(
                    child: _messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    avatarSize * 2,
                                  ),
                                  child: Image.asset(
                                    user.avatarUrl,
                                    width: avatarSize * 2,
                                    height: avatarSize * 2,
                                    fit: BoxFit.cover,
                                    opacity: const AlwaysStoppedAnimation(0.6),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.isOnline ? 'В сети' : 'Не в сети',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: user.isOnline
                                        ? Colors.purple
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 12,
                            ),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final reversedIndex =
                                  _messages.length - 1 - index;
                              final msg = _messages[reversedIndex];
                              final isMe = msg.isSentByMe;

                              final showCircles =
                                  reversedIndex + 1 >= _messages.length ||
                                  _messages[reversedIndex + 1].isSentByMe !=
                                      isMe;
                              final firstMsg =
                                  reversedIndex - 1 < 0 ||
                                  _messages[reversedIndex - 1].isSentByMe !=
                                      isMe;

                              final isSelected =
                                  _selectedMessageIndex == reversedIndex;

                              return _MessageWidget(
                                key: ValueKey(
                                  msg.timestamp.toIso8601String() + msg.text,
                                ),
                                message: msg,
                                isMe: isMe,
                                showCircles: showCircles,
                                firstMsg: firstMsg,
                                highlighted: isSelected,
                                onLongPress: (rect) =>
                                    _onSelectMessage(reversedIndex, rect),
                                onTap: () {
                                  if (isSelected) {
                                    setState(() {
                                      _selectedMessageIndex = null;
                                    });
                                  }
                                },
                              );
                            },
                          ),
                  ),
                  const Divider(height: 1),

                  // Поле ввода нового сообщения
                  Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: IgnorePointer(
                      ignoring: _selectedMessageIndex != null,
                      child: !widget.isArchive
                          ? Opacity(
                              opacity: _selectedMessageIndex != null
                                  ? 0.5
                                  : 1.0,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _controller,
                                      focusNode: _focusNode,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                        hintText: "Сообщение...",
                                        hintStyle: const TextStyle(
                                          color: Color.fromRGBO(0, 0, 0, 0.4),
                                          fontSize: 14,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: const Color.fromRGBO(
                                          0,
                                          0,
                                          0,
                                          0.07,
                                        ),
                                      ),
                                      minLines: 1,
                                      maxLines: 7,
                                      textInputAction: TextInputAction.send,
                                      onSubmitted: (_) => _sendMessage(),
                                    ),
                                  ),
                                  if (_controller.text.isNotEmpty) ...[
                                    IconButton(
                                      onPressed: _sendMessage,
                                      icon: const Icon(
                                        Icons.arrow_circle_up,
                                        color: Colors.deepPurple,
                                        size: 35,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            )
                          : CustomButton(
                              text: _isRequestSent
                                  ? "Запрос отправлен"
                                  : "Отправить запрос на переписку",
                              width: 350,
                              isEnabled: !_isRequestSent,
                              backgroundColor: _isRequestSent
                                  ? Color.fromRGBO(0, 0, 0, 0.2)
                                  : null,
                              textColor: _isRequestSent
                                  ? Color.fromRGBO(0, 0, 0, 0.4)
                                  : null,
                              onPressed: () {
                                setState(() {
                                  _isRequestSent = true;
                                });
                              },
                            ),
                    ),
                  ),
                ],
              ),

              // Затемнение и блюр при выделении
              if (_selectedMessageIndex != null)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _selectedMessageIndex = null;
                      });
                    },
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                      child: Container(
                        color: const Color.fromRGBO(0, 0, 0, 0.2),
                      ),
                    ),
                  ),
                ),

              // Позиционированное выделенное сообщение + кнопка копирования
              if (_selectedMessageIndex != null &&
                  _messageRects.containsKey(_selectedMessageIndex))
                Positioned(
                  left: _messageRects[_selectedMessageIndex!]!.left,
                  top: _messageRects[_selectedMessageIndex!]!.top - 24,
                  width: _messageRects[_selectedMessageIndex!]!.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        _messages[_selectedMessageIndex!].isSentByMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      _MessageWidget(
                        message: _messages[_selectedMessageIndex!],
                        isMe: _messages[_selectedMessageIndex!].isSentByMe,
                        showCircles: true,
                        firstMsg: true,
                        highlighted: true,
                        onLongPress: (_) {},
                        onTap: () {},
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.only(
                          left: !_messages[_selectedMessageIndex!].isSentByMe
                              ? 12
                              : 0,
                          right: _messages[_selectedMessageIndex!].isSentByMe
                              ? 12
                              : 0,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(
                              255,
                              255,
                              255,
                              0.5,
                            ),
                            minimumSize: const Size(209, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(
                                text: _messages[_selectedMessageIndex!].text,
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Сообщение скопировано'),
                              ),
                            );
                            setState(() {
                              _selectedMessageIndex = null;
                            });
                          },
                          child: SizedBox(
                            width: 150,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  "Скопировать",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.file_copy,
                                  color: Color.fromRGBO(0, 0, 0, 0.4),
                                  size: 15,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Отдельный виджет для одного сообщения с возвратом позиции при длительном нажатии
class _MessageWidget extends StatefulWidget {
  final Message message;
  final bool isMe;
  final bool showCircles;
  final bool firstMsg;
  final bool highlighted;
  final void Function(Rect rect) onLongPress;
  final VoidCallback onTap;

  const _MessageWidget({
    Key? key,
    required this.message,
    required this.isMe,
    required this.showCircles,
    required this.firstMsg,
    this.highlighted = false,
    required this.onLongPress,
    required this.onTap,
  }) : super(key: key);

  @override
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<_MessageWidget> {
  final GlobalKey _key = GlobalKey();

  void _handleLongPress() {
    final RenderBox? box =
        _key.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final position = box.localToGlobal(Offset.zero);
      final size = box.size;
      widget.onLongPress(
        Rect.fromLTWH(position.dx, position.dy, size.width, size.height),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.message;
    final timeString =
        "${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}";

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          key: _key,
          onLongPress: _handleLongPress,
          onTap: widget.onTap,
          child: Padding(
            padding: EdgeInsets.only(
              left: !widget.isMe ? 12 : 0,
              right: widget.isMe ? 12 : 0,
            ),
            child: Align(
              alignment: widget.isMe
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.isMe
                        ? const Color.fromRGBO(158, 11, 205, 1)
                        : !widget.highlighted
                        ? const Color.fromRGBO(0, 0, 0, 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        widget.isMe ? 20 : (widget.firstMsg ? 20 : 8),
                      ),
                      topRight: Radius.circular(
                        !widget.isMe ? 20 : (widget.firstMsg ? 20 : 8),
                      ),
                      bottomLeft: Radius.circular(widget.isMe ? 20 : 8),
                      bottomRight: Radius.circular(widget.isMe ? 8 : 20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            color: widget.isMe ? Colors.white : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            timeString,
                            style: TextStyle(
                              color: widget.isMe
                                  ? Colors.white70
                                  : Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                          if (widget.isMe) ...[
                            const SizedBox(width: 1),
                            Icon(
                              msg.isRead ? Icons.done_all : Icons.check_rounded,
                              size: 16,
                              color: msg.isRead
                                  ? Colors.white70
                                  : Colors.white54,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        if (widget.showCircles)
          Positioned(
            bottom: 0,
            right: widget.isMe ? 7 : null,
            left: widget.isMe ? null : 7,
            child: Container(
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                color: widget.isMe
                    ? const Color.fromRGBO(158, 11, 205, 1)
                    : !widget.highlighted
                    ? const Color.fromRGBO(223, 221, 227, 1)
                    : Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        if (widget.showCircles)
          Positioned(
            bottom: 0,
            right: widget.isMe ? 1 : null,
            left: widget.isMe ? null : 1,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: widget.isMe
                    ? const Color.fromRGBO(158, 11, 205, 1)
                    : !widget.highlighted
                    ? const Color.fromRGBO(223, 221, 227, 1)
                    : Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
