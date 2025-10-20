import 'dart:ui'; // Для lerpDouble
import 'package:flutter/material.dart';

class CyclicSmiliesAnimation extends StatefulWidget {
  final bool isAnimating;

  const CyclicSmiliesAnimation({super.key, required this.isAnimating});

  @override
  State<CyclicSmiliesAnimation> createState() => _CyclicSmiliesAnimationState();
}

class _CyclicSmiliesAnimationState extends State<CyclicSmiliesAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _shiftAnimation;

  List<String> smilies = [
    'assets/images/smileSad.png',
    'assets/images/acc.png',
    'assets/images/smileFunBig.png',
    'assets/images/smile4.png',
  ];

  final double iconWidth = 80;
  final double bigIconWidth = 200;
  final double gap = 5;

  double get totalItemWidth => iconWidth + gap;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _shiftAnimation =
        Tween<double>(begin: 0, end: -(iconWidth + gap)).animate(
          CurvedAnimation(parent: _controller, curve: Curves.linear),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            setState(() {
              final first = smilies.removeAt(0);
              smilies.add(first);
            });
            _controller.reset();
            if (widget.isAnimating) {
              _controller.forward();
            }
          }
        });

    if (widget.isAnimating) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(CyclicSmiliesAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !_controller.isAnimating) {
      _controller.forward();
    } else if (!widget.isAnimating && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _calculateScaleFactor(int i) {
    final centerPosition = iconWidth + gap;
    final itemPosition =
        i * totalItemWidth + _shiftAnimation.value + iconWidth / 2;
    final distanceToCenter = (itemPosition - centerPosition).abs();
    const maxDistance = 170;
    double scale = 1.0 - (distanceToCenter / maxDistance);
    return scale.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    // Увеличиваем ширину контейнера, чтобы вместить все смайлики
    final double containerWidth =
        (smilies.length + 1) * totalItemWidth + bigIconWidth;

    return SizedBox(
      width: containerWidth,
      height: bigIconWidth,
      child: OverflowBox(
        maxWidth: containerWidth,
        alignment: Alignment.centerLeft,
        child: AnimatedBuilder(
          animation: _shiftAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shiftAnimation.value, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(smilies.length, (i) {
                  final path = smilies[i];
                  final scale = _calculateScaleFactor(i);
                  final imgWidth = lerpDouble(iconWidth, bigIconWidth, scale)!;

                  final opacity = (i == smilies.length - 1)
                      ? _controller.value.clamp(0.0, 1.0)
                      : 1.0;

                  return Padding(
                    padding: EdgeInsets.only(right: gap),
                    child: Opacity(
                      opacity: opacity,
                      child: Image.asset(path, width: imgWidth),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}
