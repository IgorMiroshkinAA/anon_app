import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application/screens/filter_theme.dart';
import '../screens/profile_acc.dart';

import '../widgets/custom_button_icon.dart';
import '../widgets/custom_button.dart';
import '../widgets/cyclic_smilies_animation.dart';
import '../widgets/search_button_with_cancel.dart';

import '../providers/user_provider.dart';

class AccountScreen extends StatefulWidget {
  final String accountId;
  final double rating;

  const AccountScreen({super.key, required this.accountId, this.rating = 4.5});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with TickerProviderStateMixin {
  bool showAdvancedSearchButton = false;
  String? selectedTopic;

  // Для секундомера
  Timer? _timer;
  int searchSeconds = 0;

  // Для смены текста под кнопкой
  int statusTextIndex = 0;
  static const statusTexts = [
    "Пока ищем — не забудьте быть вежливым",
    "Пока ждете — придумайте классный первый вопрос!",
  ];

  // Управление позициями смайликов
  // Начальные смайлики: слева, центр (большой), справа
  final double iconSizeSide = 79;
  final double iconSizeCenter = 131;

  // Смайлики: слева, центр, справа, появляющийся справа
  List<String> smilies = [
    'assets/images/smileSad.png', // левый маленький
    'assets/images/acc.png', // центр большой
    'assets/images/smileFun.png', // правый маленький
  ];

  // Смещение анимацией, для упрощения используем отступы в пикселях
  double leftShift = 0; // для сдвига влево смайликов

  bool isSearching = false;
  bool isSearchClicked = false;
  bool isConversationsOver = false; // флаг что беседы закончились
  int availableConversations = 3; // Здесь число из backend (заглушка)

  // Вызвать вместо заглушки, если кол-во приходит с бэка
  //   Future<void> _fetchAvailableConversations() async {
  //   // здесь вызов API, получение числа
  //   // например:
  //   // final count = await backendAPI.getAvailableConversations(widget.accountId);
  //   // setState(() {
  //   //   availableConversations = count;
  //   //   isSearchClicked = true;
  //   // });
  // }

  void _onSearchPressed() {
    if (isSearching) return;
    setState(() {
      isSearchClicked = true;
      isSearching = true;

      // Заглушка: здесь вызов к backend для получения числа доступных бесед
      // Пока тестовое значение
      availableConversations = 3;

      // Если бесед нет, меняем флаг
      isConversationsOver = availableConversations == 0;

      searchSeconds = 0;
      statusTextIndex = 0;
      leftShift = 0;
    });

    // Запускаем таймер секундомера и смены текста + анимации
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        searchSeconds++;

        // Меняем текст под кнопкой на 5-й и 10-й секунде (пример)
        if (searchSeconds == 5) {
          statusTextIndex = 1;
        }

        // Сдвигаем смайлики примерно по 10 px каждую секунду (максимум 50 px)
        if (leftShift < 50) {
          leftShift += 10;
        }

        // Поиск можно прервать по времени или вручную
        // Например, после 20 сек - останавливаем поиск и меняем кнопку
        if (searchSeconds >= 20) {
          _stopSearch();
        }
      });
    });
  }

  // Остановка поиска пользователем
  void _stopSearch() {
    _timer?.cancel();
    setState(() {
      isSearching = false;
      searchSeconds = 0;

      // Например, имитируем, что после остановки беседы закончились
      availableConversations = 0;
      isConversationsOver = availableConversations == 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onOldSearchPressed() {
    setState(() {
      showAdvancedSearchButton = true;
      _onSearchPressed();
    });
  }

  void _onCancelSearch() {
    setState(() {
      showAdvancedSearchButton = false;
      // Здесь останавливать поиск и обновлять состояние
      _stopSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userName = userProvider.user.name ?? "Пользователь";
    const backgroundGradient = LinearGradient(
      colors: [Color(0xFF97CF9A), Color(0xFFFFFFFF), Color(0xFFA992E0)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final TextStyle nameStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Colors.black,
    );

    final TextStyle idStyle = TextStyle(
      fontSize: 14,
      color: Colors.grey.shade700,
      fontWeight: FontWeight.w500,
    );

    final TextStyle ratingStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color.fromRGBO(123, 47, 174, 1),
    );

    final TextStyle sectionTitleStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 32,
      color: Colors.black,
    );

    final TextStyle smallGreyStyle = const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 16,
      color: Color.fromRGBO(0, 0, 0, 0.4),
    );

    final TextStyle textGreyStyle = const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 16,
      color: Color.fromRGBO(0, 0, 0, 0.4),
    );

    final double iconSize = 79;

    return Container(
      decoration: const BoxDecoration(gradient: backgroundGradient),
      child: SafeArea(
        child: Column(
          children: [
            // --- Шапка — всегда сверху, фиксированная ---
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile-acc');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 64,
                      child: Center(
                        child: Image.asset(
                          'assets/images/iconAcc.png',
                          width: 48,
                          height: 48,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  userName,
                                  style: nameStyle.copyWith(height: 1.0),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Color.fromRGBO(0, 0, 0, 0.4),
                                size: 16,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('ID ${userProvider.user.id}', style: idStyle),
                        ],
                      ),
                    ),

                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(155, 63, 184, 0.15),
                                borderRadius: BorderRadius.circular(35),
                              ),
                              child: Text(
                                '${widget.rating}/5',
                                style: ratingStyle,
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- Основной контент занимает оставшееся место и центрирован по высоте ---
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        15 - // padding top
                        64, // высота шапки примерно
                  ),
                  child: Center(
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Весь ваш основной контент, начиная с SizedBox(height: 20),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: SizedBox(
                              height: iconSizeCenter,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  CyclicSmiliesAnimation(
                                    isAnimating: isSearching,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 50),
                            child: Center(
                              child: Text(
                                selectedTopic ?? "Все темы",
                                style: sectionTitleStyle,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Center(
                              child: Text(
                                isSearchClicked && isSearching
                                    ? statusTexts[statusTextIndex]
                                    : 'Нажмите “Настроить”, чтобы выбрать тему, и начинайте общаться!',
                                style: smallGreyStyle.copyWith(height: 1.0),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 45),
                            child: IconTextButton(
                              width: 200,
                              icon: Icon(
                                Icons.filter_list,
                                color: Colors.black,
                                size: 25,
                              ),
                              text: 'Настроить',
                              onPressed: () async {
                                final result =
                                    await showModalBottomSheet<String?>(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) =>
                                          FilterBottomSheet(isPremium: true),
                                    );

                                if (result != null && result.isNotEmpty) {
                                  setState(() {
                                    selectedTopic = result;
                                    // Сброс логики поиска для обновления экрана, если нужно
                                    isConversationsOver = false;
                                    isSearchClicked = false;
                                    availableConversations = 3;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 10),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 45),
                            child: !showAdvancedSearchButton
                                ? CustomButton(
                                    text: isConversationsOver
                                        ? 'Беседы закончились'
                                        : 'Поиск собеседника',
                                    onPressed: isConversationsOver
                                        ? null
                                        : _onOldSearchPressed,
                                    isEnabled: !isConversationsOver,
                                  )
                                : SearchButtonWithCancel(
                                    isSearching: isSearching,
                                    isConversationsOver: isConversationsOver,
                                    availableConversations:
                                        availableConversations,
                                    onSearchPressed: _onSearchPressed,
                                    onCancelPressed: _onCancelSearch,
                                    searchSeconds: searchSeconds,
                                  ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 20,
                            ),
                            child: Center(
                              child: Visibility(
                                visible: isSearchClicked,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/messagesMin.png',
                                      width: 20,
                                    ),
                                    Text(
                                      "Сегодня доступно $availableConversations бесед${availableConversations == 1 ? '' : 'ы'}",
                                      style: textGreyStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
