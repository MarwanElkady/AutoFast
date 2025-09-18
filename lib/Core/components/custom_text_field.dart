import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.type,
    this.prefix,
    this.suffix,
    this.maxLength,
    this.obscureText,
    this.validator,
    this.initialValue,
  });
  final TextEditingController controller;
  final String hint;
  final TextInputType? type;
  final Widget? prefix;
  final Widget? suffix;
  final int? maxLength;
  final bool? obscureText;
  final String? Function(String?)? validator;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: initialValue != null && initialValue!.isNotEmpty
            ? initialValue
            : hint,
        hintStyle: TextStyle(
          fontSize: 15,
          color: initialValue != null && initialValue!.isNotEmpty
              ? Colors.black87
              : Colors.grey,
        ),
        prefixIcon: prefix,
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: type,
      maxLength: maxLength,
      obscureText: obscureText ?? false,
      validator: validator,
    );
  }
}
