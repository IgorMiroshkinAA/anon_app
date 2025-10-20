import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/custom_button.dart';

class NoSubscriptionWidget extends StatelessWidget {
  final VoidCallback onSubscribePressed;

  const NoSubscriptionWidget({Key? key, required this.onSubscribePressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color.fromARGB(0, 255, 255, 255)),
      child: ClipRect(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Архив недоступен',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  'Чтобы открыть архив, нужна подписка Plus или Premium',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Приобрести подписку',
                  onPressed: onSubscribePressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
