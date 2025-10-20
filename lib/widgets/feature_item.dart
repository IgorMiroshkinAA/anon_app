import 'package:flutter/material.dart';

class FeatureItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;

  const FeatureItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minLeadingWidth: 24, // уменьшенный отступ
      leading: SizedBox(
        width: 25, // фиксированная ширина
        height: 50, // высота для выравнивания иконки
        child: Center(
          child: icon, // теперь используем виджет, а не Icon
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
    );
  }
}
