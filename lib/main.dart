import 'package:flutter/material.dart';
import 'package:flutter_application/screens/subscription_screen.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';

import 'screens/preloader_screen.dart';
import 'screens/enter_code_screen.dart';
import 'screens/email_registration_screen.dart';
import 'screens/name_registration_screen.dart';
import 'screens/age_input_screen.dart';
import 'screens/new_password_screen.dart';
import 'screens/existing_account_password_screen.dart';
import 'screens/profile_acc.dart';

import 'widgets/main_screen_wrapper.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => UserProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Small Talk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Rounded'),
      home: const PreloaderScreen(),

      routes: {
        '/email-registration': (context) => const EmailRegistrationScreen(),
        '/set-username': (context) => const NameRegistrationScreen(),
        '/age-input': (context) => const AgeInputScreen(),
        '/new-password': (context) => const NewPasswordScreen(),
        '/existing-password': (context) => ExistingAccountPasswordScreen(email: 'example@email.com'),
        '/main-screen-wrapper': (context) => const MainScreenWrapper(),
        '/profile-acc': (context) => const ProfileAcc(),
      },
    );
  }
}
