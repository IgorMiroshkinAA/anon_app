import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/animated_letter.dart';
import '../widgets/custom_button.dart';
import 'dart:ui';

class _EmojiData {
  final String path;
  final double topPercent;
  final double leftPercent;
  final int delayMs;

  _EmojiData(this.path, this.leftPercent, this.topPercent, this.delayMs);
}

class PreloaderScreen extends StatefulWidget {
  const PreloaderScreen({super.key});

  @override
  State<PreloaderScreen> createState() => _PreloaderScreenState();
}

class _PreloaderScreenState extends State<PreloaderScreen>
    with TickerProviderStateMixin {
  final Random _random = Random();
  final int emojiCount = 10;
  final List<Widget> _flyingEmojis = [];
  bool showButton = false;

  final List<_EmojiData> emojiDataList = [
    _EmojiData(
      'assets/images/smile3.png',
      0.01,
      0.2,
      50,
    ), // top: 20%, left: 10%, delay: 0 мс
    _EmojiData(
      'assets/images/smile1.png',
      0.5,
      0.1,
      350,
    ), // top: 10%, left: 50%, delay: 300 мс
    _EmojiData(
      'assets/images/smile4.png',
      -0.25,
      0.4,
      1400,
    ), // top: 10%, left: 50%, delay: 300 мс
    _EmojiData('assets/images/smile2.png', 0.1, 0.6, 650),
    _EmojiData('assets/images/smile2.png', 0.9, 0.3, 1200),
    _EmojiData('assets/images/smile4.png', 0.7, 0.5, 1000),
  ];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < emojiDataList.length; i++) {
      _flyingEmojis.add(_buildAnimatedEmoji(emojiDataList[i]));
    }

    Future.delayed(const Duration(milliseconds: 4200), () {
      setState(() => showButton = true);
    });
  }

  // Widget _buildAnimatedEmoji(_EmojiData emojiData) {
  //   final AnimationController controller = AnimationController(
  //     duration: const Duration(seconds: 3),
  //     vsync: this,
  //   );

  //   final Animation<double> animation = Tween<double>(
  //     begin: -10.0,
  //     end: 10.0,
  //   ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

  //   controller.repeat(reverse: true);

  //   return FutureBuilder(
  //     future: Future.delayed(Duration(milliseconds: emojiData.delayMs)),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState != ConnectionState.done) {
  //         return const SizedBox.shrink();
  //       }

  //       return AnimatedBuilder(
  //         animation: animation,
  //         builder: (context, child) {
  //           return Positioned(
  //             top:
  //                 MediaQuery.of(context).size.height * emojiData.topPercent +
  //                 animation.value,
  //             left: MediaQuery.of(context).size.width * emojiData.leftPercent,
  //             child: Opacity(
  //               opacity: 1,
  //               child: Image.asset(emojiData.path, width: 147, height: 147),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  Widget _buildAnimatedEmoji(_EmojiData emojiData) {
    final AnimationController waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    final Animation<double> waveAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(parent: waveController, curve: Curves.easeInOut));

    waveController.repeat(reverse: true);

    final AnimationController tapController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    final Animation<double> scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.8,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.8,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(tapController);

    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: emojiData.delayMs)),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }

        return AnimatedBuilder(
          animation: Listenable.merge([waveAnimation, tapController]),
          builder: (context, child) {
            return Positioned(
              top:
                  MediaQuery.of(context).size.height * emojiData.topPercent +
                  waveAnimation.value,
              left: MediaQuery.of(context).size.width * emojiData.leftPercent,
              child: GestureDetector(
                onTap: () {
                  tapController.forward(from: 0.0);
                  // Здесь можно добавить звук, если хотите
                },
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: Image.asset(emojiData.path, width: 147, height: 147),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Градиентный фон
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF97CF9A),
                  Color(0xFFFFFFFF),
                  Color(0xFFA992E0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Смайлики
          ..._flyingEmojis,
          // Логотип по центру
          Center(child: AnimatedWords()),
          if (showButton)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: CustomButton(
                  text: 'Погнали!',
                  onPressed: () {
                    Navigator.pushNamed(context, '/email-registration');
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AnimatedWords extends StatefulWidget {
  const AnimatedWords({super.key});

  @override
  State<AnimatedWords> createState() => _AnimatedWordsState();
}

class _AnimatedWordsState extends State<AnimatedWords> {
  bool showSmall = false;
  bool showTalk = false;
  bool showTalk2 = false;
  bool showListen = false;
  bool showSupport = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => showSmall = true);
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() => showTalk = true);
    });

    // Нижний ряд
    Future.delayed(const Duration(milliseconds: 2500), () {
      setState(() => showTalk2 = true);
    });
    Future.delayed(const Duration(milliseconds: 3200), () {
      setState(() => showListen = true);
    });
    Future.delayed(const Duration(milliseconds: 3900), () {
      setState(() => showSupport = true);
    });
  }

  // Для слов с градиентом
  Widget buildWord(
    String word,
    bool visible,
    TextStyle style,
    Gradient gradient,
  ) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: visible ? 1 : 0,
      child: ShaderMask(
        shaderCallback: (bounds) => gradient.createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: Text(word, style: style, textAlign: TextAlign.center),
      ),
    );
  }

  // Для обычного текста (без ShaderMask, просто цвет)
  Widget buildPlainWord(String word, bool visible, TextStyle style) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: visible ? 1 : 0,
      child: Text(word, style: style, textAlign: TextAlign.center),
    );
  }

  @override
  Widget build(BuildContext context) {
    final upperStyle = const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      fontFamily: 'Rounded',
      color: Colors.white,
    );

    final lowerStyle = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      fontFamily: 'Rounded',
      height: 1.0,
      letterSpacing: 0.0,
      color: Color(0x99511765),
    );

    final upperGradient = const LinearGradient(
      colors: [Color(0x00511765), Color(0xFF511765)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Первая строка (горизонтальный градиент)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSmall)
              AnimatedLetters(
                word: "Small",
                style: upperStyle,
                gradient: upperGradient,
              ),
            const SizedBox(width: 8),
            if (showTalk)
              AnimatedLetters(
                word: "Talk",
                style: upperStyle,
                gradient: upperGradient,
              ),
          ],
        ),
        const SizedBox(height: 5),
        // Вторая строка
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildPlainWord("Talk.", showTalk2, lowerStyle),
            const SizedBox(width: 5),
            buildPlainWord("Listen.", showListen, lowerStyle),
            const SizedBox(width: 5),
            buildPlainWord("Support.", showSupport, lowerStyle),
          ],
        ),
      ],
    );
  }
}
