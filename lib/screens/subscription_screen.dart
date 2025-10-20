import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/widgets/custom_button.dart';
import 'package:flutter_application/widgets/feature_item.dart';
import 'package:flutter_application/widgets/subscription_card.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/user_provider.dart';

// Модель для плана подписки
class SubscriptionPlan {
  final int id;
  final String name;
  final int maxTopics;
  final String price;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.maxTopics,
    required this.price,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      maxTopics: json['maxTopics'],
      price: json['price'],
    );
  }
}

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int selectedTab = 0;
  // int activeTab = 1; // Теперь используем данные из UserProvider

  List<SubscriptionPlan> plans = [];
  bool isLoading = true;
  String errorMessage = '';

  // final List<String> tabs = ['Бесплатный', 'Plus', 'Premium'];
  List<String> get tabs => plans.map((plan) => plan.name).toList();

  final Map<String, List<Map<String, String>>> planFeatures = {
    'Бесплатный': [
      {
        'icon': 'chat_bubble_outline',
        'title': 'Ограниченное количество чатов',
        'subtitle': 'Ежедневно в приложении доступно по три новых чата',
      },
      {
        'icon': 'topic_outlined',
        'title': 'Настройка темы разговора',
        'subtitle':
            'Выбери, о чём хочешь поговорить — найдём подходящего собеседника',
      },
      {
        'icon': 'visibility_off_outlined',
        'title': 'Анонимное общение',
        'subtitle': 'Никакой личной информации — только ник и стиль общения',
      },
      {
        'icon': 'timer',
        'title': 'Ограниченное время для общения',
        'subtitle':
            'Чат архивируется после 20-ти минут\n отсутствия активности',
      },
    ],
    'Plus': [
      {
        'icon': 'chat_bubble_outline',
        'title': 'Больше чатов',
        'subtitle': 'Получайте по 5 новых \nчатов каждый день',
      },
      {
        'icon': 'archive',
        'title': 'Архив 48 ч',
        'subtitle':
            'Cохраняем ваши переписки на двое \nсуток, чтобы вы могли вернуться\n к интересным беседам',
      },
      {
        'icon': 'double',
        'title': 'Повторный контакт',
        'subtitle': 'Можете снова начать диалог \nс понравившимся собеседником',
      },
      {
        'icon': 'age',
        'title': 'Фильтр по возрасту',
        'subtitle': 'Находите людей ближе к вашему возрасту',
      },
      {
        'icon': 'timer',
        'title': 'Ограниченное время для общения',
        'subtitle':
            'Чат архивируется после 20-ти минут\n отсутствия активности',
      },
    ],
    'Premium': [
      {
        'icon': 'chat_bubble_outline',
        'title': 'Безлимитные чаты',
        'subtitle': 'Нет ограничений — общайтесь сколько хотите',
      },
      {
        'icon': 'archive',
        'title': 'Архив навсегда',
        'subtitle':
            'Сохраняйте важные разговоры \nи возвращайтесь к ним в любое время',
      },
      {
        'icon': 'crown',
        'title': 'Приоритетный подбор',
        'subtitle':
            'Вас будут видеть первыми в очереди на новые чаты — больше внимания, быстрее отклик',
      },
      {
        'icon': 'age',
        'title': 'Фильтр по возрасту',
        'subtitle': 'Находите людей ближе к вашему возрасту',
      },
      {
        'icon': 'timer',
        'title': 'Ограниченное время для общения',
        'subtitle': 'Чат архивируется после 20-ти минут отсутствия активности',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    try {
      final response = await http.get(
        Uri.parse('http://89.109.34.227:3000/api/plans'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          plans = jsonData
              .map((plan) => SubscriptionPlan.fromJson(plan))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Ошибка загрузки планов: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Ошибка подключения: $e';
        isLoading = false;
      });
    }
  }

  Widget _getIconWidget(String iconName) {
    switch (iconName) {
      case 'chat_bubble_outline':
        return SvgPicture.asset('assets/images/messagesGray.svg');
      case 'topic_outlined':
        return SvgPicture.asset('assets/images/sort.svg');
      case 'visibility_off_outlined':
        return SvgPicture.asset('assets/images/grammerly.svg');
      case 'timer':
        return SvgPicture.asset('assets/images/timer.svg');
      case 'archive':
        return SvgPicture.asset('assets/images/archive.svg');
      case 'double':
        return SvgPicture.asset('assets/images/double.svg');
      case 'age':
        return SvgPicture.asset('assets/images/age.svg');
      case 'crown':
        return SvgPicture.asset('assets/images/crown.svg');
      default:
        return SizedBox.shrink();
    }
  }

  Future<void> _selectPlan(int planId, String planName) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Показываем индикатор загрузки
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Выбор тарифа...'),
              ],
            ),
          );
        },
      );

      await userProvider.selectPlan(planId);

      // Закрываем диалог загрузки
      Navigator.of(context).pop();

      // Показываем сообщение об успехе
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Тариф "$planName" успешно выбран!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Закрываем диалог загрузки
      Navigator.of(context).pop();

      // Показываем сообщение об ошибке
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final activePlanId = userProvider.activePlanId;

    // Находим индекс активного плана в списке
    final activeTabIndex = plans.indexWhere((plan) => plan.id == activePlanId);
    final activeTab = activeTabIndex != -1 ? activeTabIndex : 0;

    if (isLoading) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF97CF9A), Color(0xFFFFFFFF), Color(0xFFA992E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF97CF9A), Color(0xFFFFFFFF), Color(0xFFA992E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchPlans,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    if (plans.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF97CF9A), Color(0xFFFFFFFF), Color(0xFFA992E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(child: Text('Нет доступных планов')),
      );
    }

    List<Map<String, String>> selectedFeatures =
        planFeatures[tabs[selectedTab]] ?? [];

    List<Widget> featureWidgets = selectedFeatures.map((feature) {
      return FeatureItem(
        icon: _getIconWidget(feature['icon']!),
        title: feature['title']!,
        subtitle: feature['subtitle']!,
      );
    }).toList();

    bool isActive = selectedTab == activeTab;
    final planName = tabs[activeTab];
    final selectedPlan = plans[selectedTab];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF97CF9A), Color(0xFFFFFFFF), Color(0xFFA992E0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Выберите план",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(tabs.length, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => selectedTab = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selectedTab == index
                            ? const Color.fromRGBO(0, 0, 0, 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        tabs[index],
                        style: TextStyle(
                          color: selectedTab == index
                              ? Colors.black
                              : const Color.fromRGBO(0, 0, 0, 0.4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),
              SubscriptionCard(
                title: 'Small Talk ${selectedPlan.name}',
                statusText: isActive ? "Активно" : null,
                activeUntil: !isActive ? "23.06.2026" : null,
                planType: selectedPlan.name,
                price: selectedPlan.price,
              ),
              const SizedBox(height: 18),
              const Text(
                "Доступные функции",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                      bottomLeft: Radius.elliptical(25, 25),
                      bottomRight: Radius.elliptical(25, 25),
                    ),
                    color: const Color.fromRGBO(0, 0, 0, 0.05),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          children: [...featureWidgets],
                        ),
                      ),
                      if (activeTab != 0 || selectedTab == 0)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(0, 0, 0, 0.2),
                            borderRadius: BorderRadius.circular(99),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(209, 197, 237, 1),
                                blurRadius: 25,
                                offset: Offset(0, -40),
                                spreadRadius: -10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              isActive && selectedTab == 0
                                  ? "Эта подписка уже активна"
                                  : '$planName активен до: 22.06.2026',
                              style: const TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 0.4),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (activeTab == selectedTab && selectedTab != 0)
                CustomButton(
                  text: "Отменить подписку",
                  onPressed: () {
                    // Отмена подписки - переходим на бесплатный план
                    _selectPlan(1, 'Бесплатный');
                  },
                  width: double.infinity,
                  backgroundColor: const Color.fromRGBO(0, 0, 0, 0.1),
                  textColor: const Color.fromRGBO(0, 0, 0, 1),
                ),
              if (selectedTab != 0 && activeTab == 0)
                CustomButton(
                  text: "Приобрести подписку за ${selectedPlan.price}₽",
                  onPressed: () {
                    _selectPlan(selectedPlan.id, selectedPlan.name);
                  },
                  width: double.infinity,
                ),
              if (selectedTab == 2 && activeTab == 1)
                CustomButton(
                  text: "Улучшить подписку до Premium за ${plans[2].price}₽",
                  onPressed: () {
                    _selectPlan(plans[2].id, plans[2].name);
                  },
                  width: double.infinity,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
