import 'package:flutter/material.dart';

class ConstantsOnboarding {
  String title;
  String warningText;
  String hintText;
  Widget? mainWidget;

  ConstantsOnboarding({
    required this.title,
    required this.warningText,
    required this.hintText,
    this.mainWidget,
  });
}
