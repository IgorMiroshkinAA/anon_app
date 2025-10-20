import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application/widgets/text_field.dart';
import '../widgets/custom_button.dart';

import '../providers/user_provider.dart';

class NameRegistrationScreen extends StatefulWidget {
  const NameRegistrationScreen({super.key});

  @override
  State<NameRegistrationScreen> createState() => _NameRegistrationScreenState();
}

class _NameRegistrationScreenState extends State<NameRegistrationScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isValid = false;

  void _onTextChanged(String text) {
    final isValid = text.length >= 3;
    if (isValid != _isValid) {
      setState(() {
        _isValid = isValid;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      _onTextChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              'Как вас называть',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Вы можете написать свое настоящее имя \n или выдуманный никнейм',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),

            CustomTextField(
              controller: _controller,
              hintText: 'Имя или никнейм',
              fieldType: TextFieldType.name,
              onChanged: _onTextChanged,
            ),

            const SizedBox(height: 24),
            CustomButton(
              text: 'Продолжить',
              isEnabled: _isValid,
              onPressed: () async {
                final userProvider = Provider.of<UserProvider>(
                  context,
                  listen: false,
                );

                try {
                  await userProvider.setNickname(_controller.text.trim());
                  if (!mounted) return;
                  Navigator.pushNamed(context, '/age-input');
                } catch (e) {
                  // показать ошибку, например, через SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Ошибка при сохранении имени: ${e.toString()}',
                      ),
                    ),
                  );
                }
              },
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
