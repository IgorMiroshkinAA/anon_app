// reusable_text_field.dart
import 'package:flutter/material.dart';

enum TextFieldType { email, password, name }

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextFieldType fieldType;
  final bool enabled;
  final Function(String)? onChanged;
  final Color? decorationBorderColor;
  final Color? textColor;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.fieldType,
    this.enabled = true,
    this.onChanged,
    this.decorationBorderColor,
    this.textColor,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final showClear =
        widget.fieldType == TextFieldType.email &&
        widget.controller.text.isNotEmpty;
    final showEye = widget.fieldType == TextFieldType.password;
    final showCounter = widget.fieldType == TextFieldType.name;
    final bool hasError = widget.decorationBorderColor == Colors.red;

    return TextField(
      controller: widget.controller,
      obscureText: showEye ? _obscureText : false,
      keyboardType: widget.fieldType == TextFieldType.email
          ? TextInputType.emailAddress
          : TextInputType.text,
      autocorrect: false,
      enabled: widget.enabled,
      style: TextStyle(color: widget.textColor ?? Colors.black),
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        fillColor: Colors.white.withOpacity(0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: widget.decorationBorderColor ?? Colors.grey.shade400,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: hasError ? Colors.red : Colors.deepPurple,
            width: 2,
          ),
        ),
        suffixIcon: showClear
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.deepPurple),
                onPressed: () {
                  widget.controller.clear();
                  if (widget.onChanged != null) widget.onChanged!("");
                  setState(() {});
                },
              )
            : showEye
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => _obscureText = !_obscureText);
                },
              )
            : showCounter
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  widthFactor: 1.0,
                  child: Text(
                    '${widget.controller.text.length}',
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      onChanged: (value) {
        if (widget.onChanged != null) widget.onChanged!(value);
        setState(() {}); // Обновляет иконку/счётчик при изменении
      },
    );
  }
}
