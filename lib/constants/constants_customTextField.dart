import 'package:flutter/material.dart';
import 'package:miitti_app/constants/constants_styles.dart';

class ConstantsCustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool readOnly;
  final Function()? onTap;

  const ConstantsCustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      style: ConstantStyles.hintText.copyWith(color: Colors.white),
      keyboardType: keyboardType,
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
