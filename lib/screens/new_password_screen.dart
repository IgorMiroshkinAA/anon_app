import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

import '../widgets/custom_back_button.dart';
import '../widgets/text_field.dart';
import '../widgets/custom_button.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();

  bool showMismatchError = false;
  bool showLengthError = false;

  bool isValidPassword(String password) {
    if (password.length < 5) return false;
    final regex = RegExp(r'^[a-zA-Z0-9_.]+$');
    return regex.hasMatch(password);
  }

  void onContinue() async {
    final password = passwordController.text.trim();
    final repeatPassword = repeatPasswordController.text.trim();

    setState(() {
      showLengthError = false;
      showMismatchError = false;
    });

    if (!isValidPassword(password)) {
      setState(() {
        showLengthError = true;
      });
      return;
    }
    if (password != repeatPassword) {
      setState(() {
        showMismatchError = true;
      });
      return;
    }

    setState(() {
      showMismatchError = false;
    });
    try {
      final userProvider = context.read<UserProvider>();
      // Вызов API для установки пароля
      await userProvider.setPassword(password, repeatPassword);

      // Если нужно — очистить ошибки и контроллеры
      setState(() {
        showLengthError = false;
        showMismatchError = false;
      });

      if (!mounted) return;
      // Переход на следующий экран, например:
      Navigator.pushNamed(context, '/main-screen-wrapper');
    } catch (e) {
      // Обработка ошибки (например, показать SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при сохранении пароля: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // Чтобы сбрасывать ошибку при изменении текста
    passwordController.addListener(_clearErrorsOnChange);
    repeatPasswordController.addListener(_clearErrorsOnChange);
  }

  void _clearErrorsOnChange() {
    if (showLengthError || showMismatchError) {
      setState(() {
        showLengthError = false;
        showMismatchError = false;
      });
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = (showLengthError || showMismatchError)
        ? Colors.red
        : Colors.grey.shade400;

    String? errorText;
    if (showLengthError) {
      errorText = 'Пароль не соответствует требованиям';
    } else if (showMismatchError) {
      errorText = 'Пароли не совпадают';
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF97CF9A), Color(0xFFFFFFFF), Color(0xFFA992E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomBackButton(),
                        const SizedBox(height: 24),
                        const Text(
                          'Введите пароль',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 32,
                            height: 1.0,
                            letterSpacing: -0.02 * 32,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          child: const Text(
                            'Вы можете использовать a-z, и _. Минимальная длина - 5 символов',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              height: 1.2,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        CustomTextField(
                          controller: passwordController,
                          hintText: 'Пароль',
                          fieldType: TextFieldType.password,
                          enabled: true,
                          decorationBorderColor: borderColor,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: repeatPasswordController,
                          hintText: 'Повторите пароль',
                          fieldType: TextFieldType.password,
                          enabled: true,
                          decorationBorderColor: borderColor,
                        ),
                        if (errorText != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            errorText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ] else
                          const SizedBox(height: 24),
                        const Spacer(),
                        CustomButton(
                          text: 'Сохранить',
                          isEnabled: true,
                          onPressed: onContinue,
                          textColor: Colors.white,
                          width: double.infinity,
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
