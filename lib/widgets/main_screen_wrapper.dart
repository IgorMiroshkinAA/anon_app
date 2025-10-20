import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../screens/account_screen.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../models/user_registration.dart';
import '../screens/chats_screen.dart';

import 'package:flutter_application/screens/subscription_screen.dart';

class MainScreenWrapper extends StatefulWidget {
  final int initialIndex;

  const MainScreenWrapper({super.key, this.initialIndex = 0});

  @override
  State<MainScreenWrapper> createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper> {
  late int _selectedIndex;
  late List<Widget> _pages;
  void _goToMainTab() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  // final userId = userProvider.user.id ?? 0;

  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false);

    _pages = [
      AccountScreen(accountId: '1234556', rating: 4.5),
      ChatsScreen(
        onGoToMainTab: _goToMainTab,
        goToSubscription: () => _onNavItemTapped(2),
      ),
      SubscriptionScreen(),
    ];

    _selectedIndex = widget.initialIndex;
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const homeIcon = 'assets/images/home.svg';
    const homeIconSelected = 'assets/images/home-black.svg';
    const chatIcon = 'assets/images/messages-2.svg';
    const chatIconSelected = 'assets/images/messages-black.svg';
    const starIcon = 'assets/images/star.svg';
    const starIconSelected = 'assets/images/star-black.svg';

    return Scaffold(
      // Текущий выбранный экран отображается в body
      body: Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 5, right: 5, bottom: 25, top: 25),

        decoration: BoxDecoration(color: Colors.transparent),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _onNavItemTapped(0),
              child: SvgPicture.asset(
                _selectedIndex == 0 ? homeIconSelected : homeIcon,
                width: 32,
                height: 32,
              ),
            ),
            GestureDetector(
              onTap: () => _onNavItemTapped(1),
              child: SvgPicture.asset(
                _selectedIndex == 1 ? chatIconSelected : chatIcon,
                width: 32,
                height: 32,
              ),
            ),
            GestureDetector(
              onTap: () => _onNavItemTapped(2),
              child: SvgPicture.asset(
                _selectedIndex == 2 ? starIconSelected : starIcon,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
