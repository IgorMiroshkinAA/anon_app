import 'package:flutter/material.dart';

class AnimatedLetters extends StatefulWidget {
  final String word;
  final TextStyle style;
  final Gradient gradient;

  const AnimatedLetters({
    required this.word,
    required this.style,
    required this.gradient,
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedLetters> createState() => _AnimatedLettersState();
}

class _AnimatedLettersState extends State<AnimatedLetters> {
  late List<bool> _visibleLetters;

  @override
  void initState() {
    super.initState();
    _visibleLetters = List<bool>.filled(widget.word.length, false);

    for (int i = 0; i < widget.word.length; i++) {
      Future.delayed(Duration(milliseconds: 200 * i), () {
        if (mounted) {
          setState(() {
            _visibleLetters[i] = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.word.length, (index) {
        return AnimatedOpacity(
          opacity: _visibleLetters[index] ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300),
          child: ShaderMask(
            shaderCallback: (bounds) => widget.gradient.createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Text(widget.word[index], style: widget.style),
          ),
        );
      }),
    );
  }
}
