import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/main_screen_wrapper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/text_field.dart';
import '../widgets/custom_button.dart';
import 'account_screen.dart';
import 'email_registration_screen.dart';

class ExistingAccountPasswordScreen extends StatefulWidget {
  const ExistingAccountPasswordScreen({super.key});

  @override
  State<ExistingAccountPasswordScreen> createState() =>
      _ExistingAccountPasswordScreenState();
}

class _ExistingAccountPasswordScreenState
    extends State<ExistingAccountPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();

  bool showLengthError = false;
  bool showBackendError = false;
  bool isLoading = false;
  bool showRestoreButton = false;
  bool isContinueEnabled = false;

  static const String correctPassword = "12345";

  bool isValidPassword(String password) {
    if (password.length < 5) return false;
    final regex = RegExp(r'^[a-zA-Z0-9_.]+$');
    return regex.hasMatch(password);
  }

  Future<bool> checkPasswordOnBackend(String password) async {
    // final url = Uri.parse('https://backend.com/api/check_password');
    await Future.delayed(const Duration(seconds: 1));

    return password == correctPassword;

    // try {
    //   // Формируем тело запроса в формате JSON
    //   final body = jsonEncode({'password': password});

    //   final response = await http.post(
    //     url,
    //     headers: {
    //       'Content-Type': 'application/json',
    //       // добавить заголовки авторизации, если нужны
    //     },
    //     body: body,
    //   );

    //   if (response.statusCode == 200) {
    //     final data = jsonDecode(response.body);

    //     // Если, сервер возвращает { "valid": true } или { "valid": false }
    //     return data['valid'] == true;
    //   } else {
    //     // Обработка ошибок сервера
    //     print('Ошибка сервера: ${response.statusCode}');
    //     return false;
    //   }
    // } catch (e) {
    //   // Обработка ошибок запроса/сети
    //   print('Ошибка запроса: $e');
    //   return false;
    // }
  }

  void onContinue() async {
    final password = passwordController.text.trim();

    setState(() {
      showLengthError = false;
      showBackendError = false;
      isLoading = true;
    });

    if (!isValidPassword(password)) {
      setState(() {
        showLengthError = true;
        isLoading = false;
        isContinueEnabled = false;
      });
      return;
    }

    try {
      // Используем реальный email и введенный пароль

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.login(
        "login", // email из параметра экрана
        password, // реальный введенный пароль
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainScreenWrapper()),
        );
      }
    } catch (e) {
      setState(() {
        showBackendError = true;
        showRestoreButton = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: ${e.toString()}')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    passwordController.addListener(() {
      final isValid = isValidPassword(passwordController.text.trim());
      setState(() {
        isContinueEnabled = isValid && !showBackendError;
        if (isValid) {
          showLengthError = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = (showLengthError || showBackendError)
        ? Colors.red
        : Colors.grey.shade400;

    final textColor = (showLengthError || showBackendError)
        ? Colors.red
        : Colors.black;

    String? errorText;
    if (showLengthError) {
      errorText = 'Пароль не совпадает требованиям (минимум 5 английских букв)';
    } else if (showBackendError) {
      errorText = 'Неверный пароль';
    }

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
        child: SafeArea(
          child: Stack(
            children: [
              // Кнопка назад слева сверху
              Positioned(top: 12, left: 12, child: const CustomBackButton()),

              // Центрированный контент с отступами и скроллом
              Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment
                        .stretch, // Чтобы кнопка растягивалась
                    children: [
                      // Чтобы кнопка назад не присутствовала дважды, её убираем из списка детей
                      const SizedBox(
                        height: 70,
                      ), // пространство под кнопку назад
                      const Text(
                        'Введите пароль',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 32,
                          height: 1.0,
                          letterSpacing: -0.02 * 32,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Аккаунт, на который вы хотите зайти, уже защищен паролем',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.2,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 32),
                      CustomTextField(
                        controller: passwordController,
                        hintText: 'Пароль',
                        fieldType: TextFieldType.password,
                        enabled: !isLoading,
                        decorationBorderColor: borderColor,
                        textColor: textColor,
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
                      const SizedBox(height: 90),
                      CustomButton(
                        text: isLoading ? 'Загрузка...' : 'Продолжить',
                        isEnabled: isContinueEnabled && !isLoading,
                        onPressed: isContinueEnabled && !isLoading
                            ? onContinue
                            : null,
                        textColor: Colors.white,
                        width: double.infinity,
                      ),
                      const SizedBox(height: 10),
                      CustomButton(
                        text: 'Восстановить пароль',
                        isEnabled: showRestoreButton && !isLoading,
                        onPressed: showRestoreButton && !isLoading
                            ? () async {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const EmailRegistrationScreen(mode: EmailScreenMode.login),
                                  ),
                                );
                              }
                            : null,
                        backgroundColor: showRestoreButton
                            ? const Color.fromRGBO(
                                51,
                                51,
                                51,
                                1,
                              ) // темный фон при активной кнопке
                            : const Color.fromRGBO(0, 0, 0, 0.2),
                        textColor: Colors.white,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
