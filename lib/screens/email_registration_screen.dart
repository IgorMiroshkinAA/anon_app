import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application/screens/existing_account_password_screen.dart';
import 'package:flutter_application/screens/enter_code_screen.dart';
import 'package:flutter_application/widgets/text_field.dart';
import 'package:flutter_application/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class EmailRegistrationScreen extends StatefulWidget {
  const EmailRegistrationScreen({super.key});

  @override
  State<EmailRegistrationScreen> createState() => _EmailRegistrationScreenState();
}

class _EmailRegistrationScreenState extends State<EmailRegistrationScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isValidEmail = false;

  final TapGestureRecognizer _consentRecognizer = TapGestureRecognizer();
  final TapGestureRecognizer _rulesRecognizer = TapGestureRecognizer();

  bool _validateEmail(String email) {
    final emailRegExp = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    return emailRegExp.hasMatch(email);
  }

  void _onTextChanged(String text) {
    final isValid = _validateEmail(text.trim());
    if (isValid != _isValidEmail) {
      setState(() {
        _isValidEmail = isValid;
      });
    }
  }

  Future<void> _handleSubmit(String email) async {
    FocusScope.of(context).unfocus();
    final trimmedEmail = email.trim();
    if (!_validateEmail(trimmedEmail)) return;

    try {
      final userProvider = context.read<UserProvider>();
      final mode = await userProvider.initAuth(trimmedEmail); // 'login' | 'registration'

      if (!mounted) return;

      if (mode == 'login') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExistingAccountPasswordScreen(email: trimmedEmail),
          ),
        );
      } else if (mode == 'registration') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EnterCodeScreen(email: trimmedEmail),
          ),
        );
      } else {
        throw Exception('Неизвестный режим: $mode');
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}')),
      );
    }
  }

  void _launch(String url) async {
    final uri = Uri.parse(url);
    if (await launcher.canLaunchUrl(uri)) {
      await launcher.launchUrl(uri, mode: launcher.LaunchMode.platformDefault);
    } else {
      print('Не удалось открыть ссылку: $url');
    }
  }

  @override
  void initState() {
    super.initState();
    _consentRecognizer.onTap = () => _launch(
      'https://docs.google.com/document/d/1aMcCNJg4SIxNZohNgDWmdX70cHBQpXCMqGS3VShDICA/edit?usp=sharing',
    );
    _rulesRecognizer.onTap = () => _launch(
      'https://docs.google.com/document/d/1I1AymjIzH1v7r5DnNcpa_LCg5GY1BWoZrAokubxGSYQ/edit?usp=sharing',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _consentRecognizer.dispose();
    _rulesRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            const Text(
              'Укажите почту',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Мы не передаём вашу почту третьим лицам.\nТолько вам — доступ в чат.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _controller,
              hintText: 'E-mail',
              fieldType: TextFieldType.email,
              onChanged: _onTextChanged,
            ),
            const SizedBox(height: 16),
            Text.rich(
              TextSpan(
                text: 'Нажимая "Продолжить" вы даёте\n',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
                children: [
                  TextSpan(
                    text: 'Согласие на обработку персональных данных\n',
                    style: const TextStyle(
                      color: Colors.purple,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: _consentRecognizer,
                  ),
                  TextSpan(
                    text: 'Согласие с правилами использования мобильного приложения',
                    style: const TextStyle(
                      color: Colors.purple,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: _rulesRecognizer,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Продолжить',
              isEnabled: _isValidEmail,
              onPressed: _isValidEmail ? () => _handleSubmit(_controller.text) : null,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}