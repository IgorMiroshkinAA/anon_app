import 'dart:ui';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';

import 'package:flutter_application/widgets/chat_action_buttons.dart';
import 'package:flutter_application/widgets/chat_request.dart';
import 'package:flutter_application/widgets/complain_widget.dart';
import 'package:flutter_application/widgets/confirm_dialog_widget.dart';
import 'package:flutter_application/widgets/custom_button.dart';
import 'package:flutter_application/widgets/empty_state_widget.dart';
import 'package:flutter_application/widgets/feedback_widget.dart';
import 'package:flutter_application/widgets/no_subscription_widget.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/screens/chat_screen.dart';

import '../models/chat_data.dart';

import '../widgets/chat_item.dart';
import '../widgets/chat_list_item_wrapper.dart';

class ChatsScreen extends StatefulWidget {
  final VoidCallback onGoToMainTab;
  final VoidCallback goToSubscription;
  final bool hasSubscription;
  const ChatsScreen({
    Key? key,
    required this.onGoToMainTab,
    required this.goToSubscription,
    this.hasSubscription = false,
  }) : super(key: key);

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  int? _selectedActiveChatIndex;
  int? _selectedArchiveChatIndex;
  ChatData? _pendingRequestChat;
  late UserProvider _userProvider;

  // УБИРАЕМ ГЕТТЕРЫ и используем прямые ссылки в методах
  List<ChatData> _getActiveChats() => _userProvider.activeChats;
  List<ChatData> _getArchiveChats() => _userProvider.archiveChats;
  List<ChatData> _getRequestChats() => _userProvider.requestChats;

  void _deleteUser(chat, isArchive) {
    setState(() {
      if (!isArchive) {
        _userProvider.activeChats.remove(chat);
      } else {
        _userProvider.archiveChats.remove(chat);
      }
      Navigator.of(context).pop();
    });
  }

  void _addArhive(chat) {
    setState(() {
      _userProvider.activeChats.remove(chat);
      _userProvider.archiveChats.add(chat);
      Navigator.of(context).pop();
    });
  }

  void handleAccept(ChatData chat) {
    setState(() {
      _userProvider.requestChats.remove(chat);
      _userProvider.activeChats.add(
        ChatData(
          avatarUrl: 'assets/images/accGray.png',
          name: chat.name,
          lastMessage: '',
          lastMessageTime: '',
          timerLabel: '',
          newMessagesCount: 0,
          isRead: false,
          isOnline: false,
          userId: DateTime.now().millisecondsSinceEpoch,
          isRepeatRequest: true,
        ),
      );
    });
  }

  void handleDecline(ChatData chat) {
    setState(() {
      _userProvider.requestChats.remove(chat);
    });
  }

  void _removeChatFromArchive(ChatData chat) {
    setState(() {
      _userProvider.archiveChats.remove(chat);
    });
  }

  void _showConfirmDialog({
    required int index,
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
                  Navigator.pop(ctx);
                  _performActionOnChat(index, action, isArchive);
                },
                onCancel: () => Navigator.pop(ctx),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFeedbackDialog(chat) {
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
                    _addArhive(chat);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showComplainDialog(int index, bool isArchive) {
    final chatList = !isArchive ? _getActiveChats() : _getArchiveChats();
    ChatData chat = chatList[index];
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

  void _performActionOnChat(int index, String action, bool isArchive) {
    setState(() {
      final chatList = !isArchive ? _getActiveChats() : _getArchiveChats();
      ChatData chat = chatList[index];

      if (action == 'В архив') {
        if (!isArchive) {
          Future.delayed(Duration(milliseconds: 100), () {
            _showFeedbackDialog(chat);
          });
          _userProvider.activeChats.removeAt(index);
          _userProvider.archiveChats.add(chat);
          _selectedActiveChatIndex = null;
        }
      } else if (action == 'Удалить') {
        chatList.removeAt(index);
        if (isArchive) {
          _selectedArchiveChatIndex = null;
        } else {
          _selectedActiveChatIndex = null;
        }
      }
    });
  }

  void _showContactRequestPopup(ChatData chat) {
    setState(() {
      _pendingRequestChat = chat;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ConfirmDialogWidget(
          content: "${chat.name} отправил вам запрос\nна повторный контакт",
          confirmButtonText: "Принять",
          onConfirm: () {
            handleAccept(chat);
            Navigator.of(context).pop();
          },
          onCancel: () {
            handleDecline(chat);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> _loadChats() async {
    try {
      await _userProvider.refreshChats();
    } catch (e) {
      print('Ошибка загрузки чатов: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userProvider = Provider.of<UserProvider>(context, listen: false);
      _loadChats();

      // Используем метод вместо геттера
      final repeatChat = _getActiveChats().firstWhereOrNull(
        (chat) => chat.isRepeatRequest == true,
      );

      if (repeatChat != null) {
        _showContactRequestPopup(repeatChat);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Получаем провайдер для подписки на изменения
    final userProvider = Provider.of<UserProvider>(context);
    final int levelSubscription = userProvider.user.levelSubscription ?? 0;
    final bool hasSubscription = levelSubscription > 0;

    // Используем данные напрямую из провайдера
    final activeChats = userProvider.activeChats;
    final archiveChats = userProvider.archiveChats;
    final requestChats = userProvider.requestChats;

    const backgroundGradient = LinearGradient(
      colors: [Color(0xFF97CF9A), Color(0xFFFFFFFF), Color(0xFFA992E0)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    const tabTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Colors.black,
    );

    return Container(
      decoration: const BoxDecoration(gradient: backgroundGradient),
      child: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  'Чаты',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TabBar(
                dividerColor: Colors.transparent,
                labelColor: Colors.black,
                unselectedLabelColor: Color.fromRGBO(0, 0, 0, 0.4),
                indicator: BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                indicatorPadding: const EdgeInsets.symmetric(vertical: 6),
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 2,
                  vertical: 1,
                ),
                labelStyle: tabTextStyle,
                unselectedLabelStyle: tabTextStyle,
                tabs: const [
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text('Активные'),
                    ),
                  ),
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text('Архив'),
                    ),
                  ),
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text('Запросы'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(
                height: 1,
                thickness: 1,
                color: Color.fromRGBO(0, 0, 0, 0.1),
              ),
              Flexible(
                child: TabBarView(
                  children: [
                    // --- Активные ---
                    activeChats.isEmpty
                        ? EmptyStateWidget(
                            message: "Чатов пока нет",
                            text: 'Когда начнёте новый — он появится здесь',
                            img: 'assets/images/notChats.png',
                            onGoToMainTab: widget.onGoToMainTab,
                          )
                        : ListView.separated(
                            itemCount: activeChats.length,
                            separatorBuilder: (_, __) => const Divider(
                              height: 0,
                              color: Colors.transparent,
                            ),
                            itemBuilder: (context, index) {
                              final chat = activeChats[index];
                              final isSelected =
                                  _selectedActiveChatIndex == index;
                              return Column(
                                children: [
                                  ChatListItemWrapper(
                                    onLongPress: () {
                                      setState(() {
                                        _selectedActiveChatIndex = isSelected
                                            ? null
                                            : index;
                                      });
                                    },
                                    child: ChatItem(
                                      isPlusSubscription: false,
                                      archiveEndTime: DateTime.now(),
                                      chatData: chat,
                                      thisArhive: false,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ChatScreen(
                                              user: chat,
                                              deleteUser: _deleteUser,
                                              addArchive: _addArhive,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  if (isSelected)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 16,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          ChatActionButtons(
                                            onConfirmAction: (action) {
                                              if (action == 'Удалить') {
                                                _showConfirmDialog(
                                                  index: index,
                                                  action: 'Удалить',
                                                  isArchive: false,
                                                  content:
                                                      'Вы хотите удалить чаты без возможности восстановления?',
                                                  confirmButtonText: 'Удалить',
                                                );
                                              } else if (action == 'В архив') {
                                                _showConfirmDialog(
                                                  index: index,
                                                  action: 'В архив',
                                                  isArchive: false,
                                                  content:
                                                      'Вы хотите закончить выбранные чаты?',
                                                  additionalText:
                                                      'Законченные чаты перенесутся в архив',
                                                  confirmButtonText:
                                                      'Закончить',
                                                );
                                              }
                                            },
                                            onReportPressed: () {
                                              _showComplainDialog(index, false);
                                            },
                                            isArchiveContext: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),

                    // --- Архив ---
                    Center(
                      child: levelSubscription == 0
                          ? Stack(
                              children: [
                                ListView.separated(
                                  itemCount: archiveChats.length,
                                  separatorBuilder: (_, __) => const Divider(
                                    height: 0,
                                    color: Colors.transparent,
                                  ),
                                  itemBuilder: (context, index) {
                                    final chat = archiveChats[index];
                                    return Column(
                                      children: [
                                        ChatListItemWrapper(
                                          onLongPress: () {},
                                          child: ChatItem(
                                            chatData: chat,
                                            thisArhive: true,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ChatScreen(
                                                    user: chat,
                                                    deleteUser: _deleteUser,
                                                    addArchive: _addArhive,
                                                    isArchive: true,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                Positioned.fill(
                                  child: ClipRect(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 5,
                                        sigmaY: 5,
                                      ),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color.fromRGBO(230, 223, 245, 0),
                                              Color(0xFFE6DFF5),
                                              Color(0xFFE6DFF5),
                                              Color.fromRGBO(230, 223, 245, 0),
                                            ],
                                            stops: [
                                              0.0003,
                                              0.4114,
                                              0.6551,
                                              0.9997,
                                            ],
                                            transform: GradientRotation(
                                              179.97 * 3.1415927 / 180,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: NoSubscriptionWidget(
                                    onSubscribePressed: widget.goToSubscription,
                                  ),
                                ),
                              ],
                            )
                          : levelSubscription == 1
                          ? (archiveChats.isEmpty
                                ? EmptyStateWidget(
                                    message: "Чатов пока нет",
                                    text:
                                        'Здесь появляются чаты, которые вы уже закончили',
                                    img: 'assets/images/notArhive.png',
                                    onGoToMainTab: widget.onGoToMainTab,
                                  )
                                : ListView.separated(
                                    itemCount: archiveChats.length,
                                    separatorBuilder: (_, __) => const Divider(
                                      height: 0,
                                      color: Colors.transparent,
                                    ),
                                    itemBuilder: (context, index) {
                                      final chat = archiveChats[index];
                                      return Column(
                                        children: [
                                          ChatListItemWrapper(
                                            onLongPress: () {},
                                            child: ChatItem(
                                              chatData: chat,
                                              thisArhive: true,
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => ChatScreen(
                                                      user: chat,
                                                      deleteUser: _deleteUser,
                                                      addArchive: _addArhive,
                                                      isArchive: true,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ))
                          : levelSubscription == 2
                          ? ListView.separated(
                              itemCount: archiveChats.length,
                              separatorBuilder: (_, __) => const Divider(
                                height: 0,
                                color: Colors.transparent,
                              ),
                              itemBuilder: (context, index) {
                                final chat = archiveChats[index];
                                return Column(
                                  children: [
                                    ChatListItemWrapper(
                                      onLongPress: () {},
                                      child: ChatItem(
                                        chatData: chat,
                                        thisArhive: true,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ChatScreen(
                                                user: chat,
                                                deleteUser: _deleteUser,
                                                addArchive: _addArhive,
                                                isArchive: true,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                          : EmptyStateWidget(
                              message: "Чатов пока нет",
                              text:
                                  'Здесь появляются чаты, которые вы уже закончили',
                              img: 'assets/images/notArhive.png',
                              onGoToMainTab: widget.onGoToMainTab,
                            ),
                    ),

                    // --- Запросы ---
                    Center(
                      child: requestChats.isEmpty
                          ? EmptyStateWidget(
                              message: "Запросов пока нет",
                              text:
                                  'Когда придет новый запрос — он появится здесь',
                              img: 'assets/images/notChats.png',
                              onGoToMainTab: widget.onGoToMainTab,
                            )
                          : ListView.builder(
                              itemCount: requestChats.length,
                              itemBuilder: (context, index) {
                                final chatReq = requestChats[index];
                                return ChatRequestItem(
                                  chatData: chatReq,
                                  thisArhive: false,
                                  onAccept: () => handleAccept(chatReq),
                                  onDecline: () => handleDecline(chatReq),
                                );
                              },
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
