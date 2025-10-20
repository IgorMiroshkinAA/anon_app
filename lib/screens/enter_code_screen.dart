import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class EnterCodeScreen extends StatefulWidget {
  final String email;
  const EnterCodeScreen({super.key, required this.email});

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  String _code = '';
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF97CF9A), Color(0xFFFFFFFF), Color(0xFFA992E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Введите код',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Rounded',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Мы отправили код на почту\n${widget.email}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 30),

            // Внутри Column:
            SizedBox(
              width: 220, // Управляем шириной всей группы полей
              child: PinCodeTextField(
                appContext: context,
                length: 4,
                keyboardType: TextInputType.number,
                obscureText: false,
                animationType: AnimationType.fade,
                animationDuration: const Duration(milliseconds: 300),
                onChanged: (value) {
                  setState(() {
                    _code = value;
                    if (_isError && value != '1234') {
                      _isError = false;
                    }
                  });
                },
                onCompleted: (value) async {
                  try {
                    await context.read<UserProvider>().verifyCode(value);
                    // Если успешно — переход на экран установки имени
                    if (mounted) {
                      Navigator.pushNamed(context, '/set-username');
                    }
                  } catch (e) {
                    // Ошибка — показать сообщение об ошибке
                    setState(() {
                      _isError = true;
                    });
                  }
                },
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 56,
                  fieldWidth: 48,
                  activeFillColor: Colors.transparent,
                  selectedFillColor: Colors.transparent,
                  inactiveFillColor: Colors.transparent,
                  inactiveColor: _isError ? Colors.red : Color(0xFFE3D8E6),
                  selectedColor: _isError ? Colors.red : Color(0xFFA149BD),
                  activeColor: _isError ? Colors.red : Color(0xFFA149BD),
                ),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
            ),
            if (_isError)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Неверный код',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),

            const SizedBox(height: 24),

            // Кнопка / Таймер
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _secondsRemaining == 0
                    ? () async {
                        try {
                          await context.read<UserProvider>().resendCode(
                            widget.email,
                          );
                          _startTimer();
                        } catch (e) {
                          // показать ошибку
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Ошибка при повторном запросе кода',
                              ),
                            ),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _secondsRemaining == 0
                      ? Colors.black
                      : Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  _secondsRemaining == 0
                      ? 'Запросить повторно'
                      : 'Запросить повторно через: 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
