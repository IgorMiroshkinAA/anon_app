import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/custom_button.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';

class FilterBottomSheet extends StatefulWidget {
  final bool isPremium;

  const FilterBottomSheet({Key? key, required this.isPremium})
    : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  RangeValues selectedAgeRange = const RangeValues(16, 47);
  String? selectedTopics;

  final List<_Topic> topics = [
    _Topic(label: 'Отношения', icon: Icons.favorite),
    _Topic(label: 'Хобби', icon: Icons.brush),
    _Topic(label: 'Учеба', icon: Icons.book),
    _Topic(label: 'Работа', icon: Icons.work),
    _Topic(label: 'Одиночество', icon: Icons.person),
    _Topic(label: 'Здоровье', icon: Icons.health_and_safety),
    _Topic(label: 'Семья', icon: Icons.groups),
    _Topic(label: 'Без темы', icon: Icons.chat_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    const backgroundGradient = LinearGradient(
      colors: [
        Color.fromRGBO(197, 228, 192, 1),
        Color(0xFFFFFFFF),
        Color.fromRGBO(217, 185, 232, 1),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final media = MediaQuery.of(context);
    final screenHeight = media.size.height;
    final screenWidth = media.size.width;

    final maxHeight = screenHeight * 0.86;

    // Паддинги и размеры
    final horizontalPadding = screenWidth * 0.06;
    final verticalPaddingTop = 10.0;
    final verticalPaddingBottom = 10.0;
    final iconContainerSize = screenWidth * 0.18;
    final iconSize = screenWidth * 0.09;
    final gridSpacing = screenWidth * 0.08;
    final sliderWidth = screenWidth;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      padding: EdgeInsets.fromLTRB(
        0.0,
        verticalPaddingTop,
        0.0,
        verticalPaddingBottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        gradient: backgroundGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Настроить фильтры',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.05,
              ),
            ),
            SizedBox(height: verticalPaddingTop),

            // Возраст
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: horizontalPadding),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!widget.isPremium) ...[
                        Icon(
                          Icons.lock_rounded,
                          size: 17, // подберите размер по вкусу
                          color:
                              Colors.grey.shade400, // цвет подходящий по стилю
                        ),
                        SizedBox(
                          width: 6,
                        ), // небольшой отступ между иконкой и текстом
                      ],
                      Text(
                        'ВОЗРАСТ СОБЕСЕДНИКА',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: screenWidth * 0.03,
                          color: const Color.fromRGBO(0, 0, 0, 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!widget.isPremium)
                  Padding(
                    padding: EdgeInsets.only(right: horizontalPadding),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding * 0.5,
                        vertical: verticalPaddingTop * 0.17,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Color.fromRGBO(0, 0, 0, 0.05),
                      ),
                      child: Text(
                        'PLUS',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Color.fromRGBO(0, 0, 0, 0.3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.only(right: horizontalPadding),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding * 0.5,
                        vertical: verticalPaddingTop * 0.17,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Color.fromRGBO(161, 73, 189, 0.1),
                      ),
                      child: Text(
                        '${selectedAgeRange.start.toInt()}–${selectedAgeRange.end.toInt()}',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            IgnorePointer(
              ignoring: !widget.isPremium,
              child: Opacity(
                opacity: widget.isPremium ? 1.0 : 0.9,
                child: SizedBox(
                  width: sliderWidth,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 1,
                      activeTrackColor: widget.isPremium
                          ? Colors.purple
                          : Color.fromRGBO(126, 120, 128, 1),
                      inactiveTrackColor: widget.isPremium
                          ? Colors.purple.withOpacity(0.3)
                          : Color.fromRGBO(0, 0, 0, 0.1),
                      thumbColor: widget.isPremium
                          ? Colors.purple
                          : Color.fromRGBO(126, 120, 128, 1),
                      overlayColor: widget.isPremium
                          ? Colors.purple.withOpacity(0.2)
                          : Color.fromRGBO(0, 0, 0, 0.1),
                    ),
                    child: RangeSlider(
                      values: selectedAgeRange,
                      min: 16,
                      max: 100,
                      divisions: 100,
                      labels: RangeLabels(
                        '${selectedAgeRange.start.toInt()}',
                        '${selectedAgeRange.end.toInt()}',
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          selectedAgeRange = values;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: verticalPaddingTop),

            // Темы
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: horizontalPadding),
                child: Text(
                  'ТЕМА ДЛЯ РАЗГОВОРА',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.03,
                    color: const Color.fromRGBO(0, 0, 0, 0.4),
                  ),
                ),
              ),
            ),
            SizedBox(height: verticalPaddingTop * 2),

            Center(
              child: SizedBox(
                width: screenWidth,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: gridSpacing,
                  runSpacing: verticalPaddingTop,
                  children: topics.map((topic) {
                    final isSelected = selectedTopics == topic.label;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selectedTopics == topic.label) {
                            selectedTopics =
                                null; // или можно запретить отменять выбор, оставлять одну тему всегда
                          } else {
                            selectedTopics = topic.label;
                          }
                        });
                      },
                      child: SizedBox(
                        width: iconContainerSize + 10,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InnerShadow(
                              shadows: [
                                Shadow(
                                  color: Colors.white.withValues(
                                    alpha: isSelected ? (1.0 * 255) : 0.0,
                                    red: 255,
                                    green: 255,
                                    blue: 255,
                                  ),
                                  blurRadius: 999,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                              child: Container(
                                height: iconContainerSize,
                                width: iconContainerSize,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.purple.shade50
                                      : const Color.fromRGBO(0, 0, 0, 0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.purple
                                        : const Color.fromRGBO(0, 0, 0, 0.0),
                                    width: 3,
                                  ),
                                ),
                                child: Container(
                                  height: iconContainerSize,
                                  width: iconContainerSize,
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(0, 0, 0, 0.0),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color.fromRGBO(0, 0, 0, 0.0),
                                      width: 3,
                                    ),
                                  ),
                                  child: Icon(
                                    topic.icon,
                                    color: isSelected
                                        ? Colors.purple
                                        : const Color.fromRGBO(0, 0, 0, 0.6),
                                    size: iconSize,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: verticalPaddingTop * 0.33),
                            Text(
                              topic.label,
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                              textAlign: TextAlign.center,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: screenWidth * 0.032,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            SizedBox(height: verticalPaddingBottom + 20),

            CustomButton(
              text: 'Сохранить',
              onPressed: () {
                // // Возвращаем true как успешное сохранение
                // Navigator.of(context).pop(true);
                // print('Темы: $selectedTopics');
                // print(
                //   'Возраст: ${selectedAgeRange.start.toInt()} - ${selectedAgeRange.end.toInt()}',
                // );
                Navigator.of(context).pop(selectedTopics);
              },
            ),

            SizedBox(height: verticalPaddingBottom + 20),
          ],
        ),
      ),
    );
  }
}

class _Topic {
  final String label;
  final IconData icon;

  const _Topic({required this.label, required this.icon});
}
