import 'package:flutter/material.dart';
import 'custom_button.dart';

class FeedbackWidget extends StatefulWidget {
  final String content;
  final String? additionalText;
  final VoidCallback onConfirm;

  const FeedbackWidget({
    Key? key,
    required this.content,
    this.additionalText,
    required this.onConfirm,
  }) : super(key: key);

  @override
  _FeedbackWidgetState createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  int? selectedNumber;
  final TextEditingController _textController = TextEditingController();
  final int maxChars = 60;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Widget _buildNumberCircle(int number) {
    bool isSelected = selectedNumber == number;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedNumber = number;
        });
      },
      child: Container(
        width: 48,
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.purple
              : Color.fromRGBO(155, 63, 184, 0.15),
          shape: BoxShape.circle,
          // border: Border.all(color: Colors.purple, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          number.toString(),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.purple,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD1C5ED), Color(0xFFFFFFFF), Color(0xFFCCE2CD)],
          stops: [0, 0.4115, 1.2],
          transform: GradientRotation(180.13 * 3.1415927 / 180),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.content,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => _buildNumberCircle(index + 1),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: _textController.text.isNotEmpty
                    ? const Color.fromRGBO(
                        161,
                        73,
                        189,
                        1,
                      ) // фиолетовый цвет, когда текст есть
                    : const Color.fromRGBO(
                        0,
                        0,
                        0,
                        0.1,
                      ), // изначальный цвет, когда пусто
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                TextField(
                  controller: _textController,
                  maxLines: 4,
                  maxLength: maxChars,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    hintText: 'Напишите отзыв',
                  ),
                  onChanged: (text) {
                    setState(() {}); // обновим состояние для счётчика и бордера
                  },
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6, bottom: 4),
                    child: Text(
                      '${maxChars - _textController.text.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),
          CustomButton(
            width: double.infinity,
            text: "Оценить",
            onPressed: widget.onConfirm,
          ),
        ],
      ),
    );
  }
}
