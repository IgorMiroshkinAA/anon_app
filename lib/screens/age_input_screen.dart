import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

import '../widgets/custom_button.dart';
import '../widgets/custom_back_button.dart';

class AgeInputScreen extends StatefulWidget {
  const AgeInputScreen({super.key});

  @override
  State<AgeInputScreen> createState() => _AgeInputScreenState();
}

class _AgeInputScreenState extends State<AgeInputScreen> {
  final int currentYear = DateTime.now().year;
  final List<String> months = [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь',
  ];

  int selectedDay = DateTime.now().day;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year - 15;

  int calculateAge() {
    final now = DateTime.now();
    final birthDate = DateTime(selectedYear, selectedMonth, selectedDay);
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  int getDaysInMonth(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0);
    return lastDay.day;
  }

  @override
  Widget build(BuildContext context) {
    final age = calculateAge();
    final isAgeValid = age > 15;
    final ageColor = isAgeValid ? Colors.deepPurple : Colors.red;
    final daysInMonth = getDaysInMonth(selectedYear, selectedMonth);
    // в build()

    final Color backgroundColor = isAgeValid
        ? const Color.fromRGBO(161, 73, 189, 0.1) // светло-фиолетовый
        : const Color.fromRGBO(255, 96, 96, 0.2); // светло-красный

    final Color textColor = isAgeValid
        ? const Color(0xFF511765) // глубокий фиолетовый
        : const Color(0xFFB00020); // красный

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF97CF9A), Color(0xFFFFFFFF), Color(0xFFA992E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 5),
                  const Text(
                    "Укажите свой возраст",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),

                  // Барабаны с рамкой
                  SizedBox(
                    height: 130,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          children: [
                            // День
                            _buildDrum(
                              itemCount: daysInMonth,
                              selectedIndex: selectedDay - 1,
                              onSelected: (index) {
                                setState(() {
                                  selectedDay = index + 1;
                                });
                              },
                              itemBuilder: (index) => "${index + 1}",
                            ),
                            // Месяц
                            _buildDrum(
                              itemCount: months.length,
                              selectedIndex: selectedMonth - 1,
                              onSelected: (index) {
                                setState(() {
                                  selectedMonth = index + 1;
                                  final maxDay = getDaysInMonth(
                                    selectedYear,
                                    selectedMonth,
                                  );
                                  if (selectedDay > maxDay)
                                    selectedDay = maxDay;
                                });
                              },
                              itemBuilder: (index) => months[index],
                            ),
                            // Год
                            _buildDrum(
                              itemCount: currentYear - 1900 + 1,
                              selectedIndex: currentYear - selectedYear,
                              onSelected: (index) {
                                setState(() {
                                  selectedYear = currentYear - index;
                                  final maxDay = getDaysInMonth(
                                    selectedYear,
                                    selectedMonth,
                                  );
                                  if (selectedDay > maxDay)
                                    selectedDay = maxDay;
                                });
                              },
                              itemBuilder: (index) => "${currentYear - index}",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    margin: const EdgeInsets.only(top: 24, bottom: 70),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: Text(
                      "$age лет",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  CustomButton(
                    text: "Продолжить",
                    isEnabled: isAgeValid,
                    onPressed: isAgeValid
                        ? () async {
                            try {
                              await context.read<UserProvider>().setAge(
                                age,
                              ); // Отправка на сервер в провайдере

                              // Переход на следующий экран, например:
                              if (!mounted) return;
                              Navigator.pushNamed(context, '/new-password');
                            } catch (e) {
                              // Обработка ошибок, например показ Snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Ошибка сохранения возраста: ${e.toString()}',
                                  ),
                                ),
                              );
                            }
                          }
                        : null,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomBackButton(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Expanded _buildDrum({
    required int itemCount,
    required int selectedIndex,
    required void Function(int index) onSelected,
    required String Function(int index) itemBuilder,
  }) {
    return Expanded(
      child: ListWheelScrollView.useDelegate(
        itemExtent: 30,
        diameterRatio: 1.2,
        perspective: 0.01,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onSelected,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            final isSelected = index == selectedIndex;
            return Center(
              child: Text(
                itemBuilder(index),
                style: TextStyle(
                  fontSize: 17,
                  color: isSelected ? Colors.black : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
