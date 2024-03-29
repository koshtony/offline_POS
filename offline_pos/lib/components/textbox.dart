import 'package:flutter/material.dart';

class TextBox extends StatelessWidget {
  final String hint;
  final controller;
  final initial;
  final bool hidden;

  TextBox(
      {super.key,
      required this.hint,
      required this.controller,
      required this.initial,
      this.hidden = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
          controller: controller,
          obscureText: hidden,
          decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            fillColor: Colors.grey.shade200,
            filled: true,
            hintText: hint,
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please Enter $hint';
            } else {
              return null;
            }
          }),
    );
  }
}
