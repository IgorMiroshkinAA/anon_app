import 'package:flutter/material.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';

class SubscriptionCard extends StatelessWidget {
  final String title;
  final String? statusText;
  final String? activeUntil;
  final String planType;
  final String? price;

  const SubscriptionCard({
    Key? key, // Added Key? key to constructor
    required this.title,
    this.statusText,
    this.activeUntil,
    required this.planType,
    this.price,
  }) : super(key: key);

  String _getPriceForPlan(String planType) {
    switch (planType) {
      case 'Plus':
        return '$price ₽/мес';
      case 'Premium':
        return '$price ₽/мес';
      default:
        return 'Бесплатно';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Круги как декоративные элементы (под InnerShadow)
          Positioned(
            top: -25,
            right: -40,
            child: Container(
              width: 78,
              height: 78,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(208, 98, 230, 1),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -28,
            child: Container(
              width: 104,
              height: 104,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(208, 98, 230, 1),
              ),
            ),
          ),

          // Основной контент с InnerShadow
          InnerShadow(
            shadows: [
              Shadow(
                color: const Color.fromRGBO(171, 0, 228, 0.6),
                blurRadius: 20,
                offset: Offset.zero,
              ),
            ],
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ), // Removed from here and added to ClipRRect
                color: Color.fromRGBO(247, 221, 255, 0.9),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(81, 23, 101, 1),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _getPriceForPlan(planType),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(81, 23, 101, 0.6),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (statusText != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(221, 163, 240, 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusText!.toUpperCase(),
                            style: const TextStyle(
                              color: Color.fromRGBO(81, 23, 101, 1),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
