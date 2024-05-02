// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/data/person_activity.dart';
import 'package:miitti_app/utils/auth_provider.dart';
import 'package:miitti_app/utils/utils.dart';
import 'package:miitti_app/widgets/my_elevated_button.dart';
import 'package:provider/provider.dart';

import '../../constants/constants.dart';

class AP2Text extends StatefulWidget {
  const AP2Text({
    super.key,
    required this.activity,
    required this.onActivityDataChanged,
    required this.controller,
  });

  final PersonActivity activity;
  final Function(PersonActivity) onActivityDataChanged;
  final PageController controller;

  @override
  State<AP2Text> createState() => _AP2TextState();
}

class _AP2TextState extends State<AP2Text> {
  // Controllers and Focus Nodes for text fields
  TextEditingController titleController = TextEditingController();
  FocusNode titleFocusNode = FocusNode();

  TextEditingController subTitleController = TextEditingController();
  FocusNode subTitleFocusNode = FocusNode();

  // Variables for the switch
  bool isMoneyRequired = false;
  String textValue = 'Maksuton, ei vaadi pääsylippua';

  @override
  void initState() {
    super.initState();
    titleController.text = widget.activity.activityTitle;
    subTitleController.text = widget.activity.activityDescription;
    isMoneyRequired = widget.activity.isMoneyRequired;
  }

  @override
  void dispose() {
    // Dispose the controllers and focus nodes
    super.dispose();
    titleController.dispose();
    titleFocusNode.dispose();
    subTitleController.dispose();
    subTitleFocusNode.dispose();
  }

  void toggleSwitch(bool value) {
    // Toggle the switch value and update the text accordingly
    setState(() {
      isMoneyRequired = !isMoneyRequired;
      textValue = isMoneyRequired
          ? 'Maksullinen, vaatii pääsylipun'
          : 'Maksuton, ei vaadi pääsylippua';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 5.w),
                children: [
                  getSomeSpace(20),
                  getMiittiActivityText(
                      'Mitä haluaisit kertoa muille miitistä'),
                  getSomeSpace(10),
                  getOurTextField(
                    myPadding: EdgeInsets.all(10.w),
                    myKeyboardType: TextInputType.text,
                    hintText: 'Kirjoita ensin ytimekäs otsikko...',
                    myController: titleController,
                    myFocusNode: titleFocusNode,
                    myOnTap: () {
                      if (titleFocusNode.hasFocus) {
                        titleFocusNode.unfocus();
                      }
                    },
                    maxLenght: 30,
                  ),
                  getOurTextField(
                    myPadding: EdgeInsets.all(10.w),
                    myKeyboardType: TextInputType.text,
                    borderRadius: 15,
                    hintText: 'Mitä muuta haluat kertoa miitistä...',
                    myOnTap: () {
                      if (subTitleFocusNode.hasFocus) {
                        subTitleFocusNode.unfocus();
                      }
                    },
                    myController: subTitleController,
                    maxLines: 7.sp.toInt(),
                    myFocusNode: subTitleFocusNode,
                    maxLenght: 150,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        textValue,
                        style: Styles.bodyTextStyle,
                      ),
                      Switch(
                        value: isMoneyRequired,
                        onChanged: toggleSwitch,
                        activeColor: AppColors.purpleColor,
                        activeTrackColor: AppColors.lightPurpleColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            getSomeSpace(10),
            MyElevatedButton(
              onPressed: () {
                if (titleFocusNode.hasFocus) titleFocusNode.unfocus();
                if (subTitleFocusNode.hasFocus) subTitleFocusNode.unfocus();
                if (titleController.text.isNotEmpty &&
                    subTitleController.text.isNotEmpty) {
                  // Update the activity object with the entered data
                  widget.activity.activityTitle = titleController.text.trim();
                  widget.activity.activityDescription = subTitleController.text;

                  widget.activity.isMoneyRequired = isMoneyRequired;
                  widget.onActivityDataChanged(widget.activity);

                  // Move to the next page using the provided controller
                  /*widget.controller.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.linear,
                  );*/

                  storeData();
                } else {
                  showSnackBar(
                      context,
                      'Varmista, että täytät kaikki tyhjät kohdat ja yritä uudelleen!',
                      Colors.red.shade800);
                }
              },
              child: Text(
                "Seuraava",
                style: Styles.bodyTextStyle,
              ),
            ),
            getSomeSpace(25),
            GestureDetector(
              onTap: () {
                if (titleFocusNode.hasFocus) titleFocusNode.unfocus();
                if (subTitleFocusNode.hasFocus) subTitleFocusNode.unfocus();
                Navigator.pop(context);
              },
              child: Text(
                "Peruuta",
                style: Styles.bodyTextStyle,
              ),
            ),
            getSomeSpace(20),
          ],
        ),
      ),
    );
  }

  void storeData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.saveMiittiActivityDataToFirebase(
      context: context,
      activityModel: widget.activity,
    );
  }
}
