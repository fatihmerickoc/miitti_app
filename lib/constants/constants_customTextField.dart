import 'package:flutter/material.dart';
import 'package:miitti_app/constants/constants_styles.dart';

class ConstantsCustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;

  const ConstantsCustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: ConstantStyles.hintText.copyWith(color: Colors.white),
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: ConstantStyles.pink,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: ConstantStyles.pink, width: 2.0),
        ),
        hintText: hintText,
        hintStyle: ConstantStyles.hintText,
      ),
    );
  }
}
