import 'package:flutter/material.dart';
import 'package:miitti_app/constants/constants_styles.dart';

class ConstantsCustomButton extends StatelessWidget {
  final String buttonText;
  final EdgeInsetsGeometry? padding;

  final bool isWhiteButton;

  final Function() onPressed;

  const ConstantsCustomButton({
    required this.buttonText,
    this.isWhiteButton = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 140,
      vertical: 12,
    ),
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(
                color: isWhiteButton
                    ? const Color(0xFFFAFAFD).withOpacity(0.6)
                    : ConstantStyles.pink,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isWhiteButton
                    ? [
                        const Color(0xFFFAFAFD).withOpacity(0.1),
                        const Color(0xFFFAFAFD).withOpacity(0.1),
                      ]
                    : [
                        ConstantStyles.pink.withOpacity(0.1),
                        ConstantStyles.orange.withOpacity(0.1)
                      ],
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: padding,
          ),
          child: Text(
            buttonText,
            style: ConstantStyles.body,
          ),
        ),
      ],
    );
  }
}
