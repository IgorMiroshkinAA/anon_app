import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/rating_box.dart';
import '../widgets/custom_button_icon.dart';

class ProfileAcc extends StatelessWidget {
  const ProfileAcc({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final userName = userProvider.user.name ?? 'Пользователь';
    final userId = userProvider.user.id ?? 0;
    const backgroundGradientGray = LinearGradient(
      colors: [
        Color.fromARGB(255, 238, 235, 235),
        Color.fromARGB(255, 129, 123, 123),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    const backgroundGradient = LinearGradient(
      colors: [Color(0xFF97CF9A), Color(0xFFFFFFFF), Color(0xFFA992E0)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    void _showLogoutDialog() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: 300,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            gradient: backgroundGradient,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  'Вы точно хотите выйти с аккаунта?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Выйти с аккаунта',
                onPressed: () {
                  // Логика выхода из аккаунта
                  Navigator.of(context).pop(); // закрываем модалку
                  // Добавьте здесь вызов провайдера для очистки данных или логаута
                },
                width: double.infinity,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Отмена',
                isEnabled: true,
                onPressed: () => Navigator.of(context).pop(),
                width: double.infinity,
                backgroundColor: Color.fromRGBO(0, 0, 0, 0.1),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      // --- AppBar с кастомной кнопкой назад ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CustomBackButton(
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          // const SizedBox(width: 75),
                          Expanded(
                            child: Center(
                              child: Image.asset(
                                'assets/images/accBigIcon.png',
                                width: 100,
                                height: 100,
                              ),
                            ),
                          ),
                          SizedBox(width: 35),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // --- Имя и ID с иконкой и статусом ---
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ID $userId',

                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.circle,
                                color: Color.fromRGBO(126, 120, 128, 1),
                                size: 4,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'В сети',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.purple,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // --- Карточка подписки ---
                          RutingBox(text: '4.5/5', textTitle: 'ОЦЕНКА'),

                          const SizedBox(height: 20),

                          // --- Меню с иконками и текстом внутри контейнера с скруглением ---
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 0,
                            ),
                            decoration: BoxDecoration(
                              gradient: backgroundGradientGray,
                              borderRadius: BorderRadius.circular(24),
                              color: Colors.white.withOpacity(0.3),
                              // color: Colors.transparent,
                            ),
                            child: Column(
                              children: [
                                _buildMenuItem(Icons.person, 'Аккаунт', () {
                                  // Реализуйте переход/логику
                                }),
                                _buildMenuItem(
                                  Icons.notifications,
                                  'Уведомления',
                                  () {
                                    // Реализуйте переход/логику
                                  },
                                ),
                                _buildMenuItem(
                                  Icons.note_rounded,
                                  'Политика',
                                  () {
                                    // Реализуйте переход/логику
                                  },
                                ),
                                _buildMenuItem(
                                  Icons.note_rounded,
                                  'Оферта',
                                  () {
                                    // Реализуйте переход/логику
                                  },
                                ),
                                _buildMenuItem(
                                  Icons.assignment_turned_in,
                                  'Правила использования приложения',
                                  () {
                                    // Реализуйте переход/логику
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          IconTextButton(
                            icon: Image.asset('assets/images/logout.png'),
                            text: 'Выйти с аккаунта',
                            onPressed: _showLogoutDialog,
                            width: double.infinity,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Вспомогательный метод для меню
  Widget _buildMenuItem(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: Row(
          children: [
            Icon(icon, color: Color.fromRGBO(0, 0, 0, 0.6)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
