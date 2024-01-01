import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miitti_app/constants/constants.dart';
import 'package:miitti_app/widgets/myElevatedButton.dart';

class QuestionAnswer extends StatefulWidget {
  Map<String, String>? recievedData;
  QuestionAnswer({required this.recievedData, super.key});

  @override
  State<QuestionAnswer> createState() => _QuestionAnswerState();
}

class _QuestionAnswerState extends State<QuestionAnswer> {
  final List<bool> _isExpandedList = List.generate(15, (_) => false);
  final List<bool> _isSavedList = List.generate(15, (_) => false);
  final List<TextEditingController> _isControllers =
      List.generate(15, (_) => TextEditingController());

  final List<GlobalKey> _itemKeys = List.generate(15, (index) => GlobalKey());

  final _scrollController = ScrollController();

  int answerLimit = 5;
  int currentAnswers = 0;

  Map<String, String> answers = {};

  final _justFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPreviousData();
  }

  @override
  void dispose() {
    _justFocusNode.dispose();
    super.dispose();
  }

  void getPreviousData() {
    if (widget.recievedData != null) {
      answers = widget.recievedData!;
      for (int i = 0; i < questionOrder.length; i++) {
        String question = questionOrder[i];
        if (answers.containsKey(question)) {
          _isControllers[i].text = answers[question]!;
          _isSavedList[i] = true;
          currentAnswers++;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),
          child: Column(
            children: [
              _buildHeader(),
              SizedBox(height: 10.h),
              _buildQuestionList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    int numLeftToAnswer = answerLimit - currentAnswers;
    return Row(
      children: [
        _buildBackButton(),
        SizedBox(width: 10.h),
        _buildHeaderText(numLeftToAnswer),
      ],
    );
  }

  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        gradient: const LinearGradient(
          colors: [AppColors.lightRedColor, AppColors.orangeColor],
        ),
      ),
      child: TextButton(
        onPressed: () => Navigator.pop(context, answers),
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          minimumSize: Size(60.h, 60.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Icon(Icons.arrow_back, color: Colors.white, size: 30.r),
      ),
    );
  }

  Widget _buildHeaderText(int numLeftToAnswer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentAnswers > 0 ? 'Hyvältä näyttää!' : 'Kerro enemmän',
          style: Styles.sectionTitleStyle,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          currentAnswers > 0
              ? 'Voit vastata vielä $numLeftToAnswer Q&A -korttin'
              : 'Valitse Q&A -korttia, joihin haluat vastata',
          style: TextStyle(
            fontFamily: 'Rubik',
            fontSize: 13.sp,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildQuestionList() {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: questionOrder.length,
        itemBuilder: (context, index) => _buildQuestionTile(index),
      ),
    );
  }

  Widget _buildQuestionTile(int index) {
    String question = questionOrder[index];
    bool answered = answers.containsKey(question);

    return Column(
      key: _itemKeys[index], // Assign the key here
      children: [
        GestureDetector(
          onTap: () {
            if (currentAnswers < 5) {
              setState(() {
                _isExpandedList[index] = !_isExpandedList[index];
                if (_isExpandedList[index]) {
                  // If the item has expanded, then scroll to it
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Scrollable.ensureVisible(
                      _itemKeys[index].currentContext!,
                      duration: const Duration(milliseconds: 300),
                    );
                  });
                }
              });
            }
          },
          child: _buildQuestionRow(question, index),
        ),
        if (_isExpandedList[index]) _buildAnswerForm(index, answered, question),
      ],
    );
  }

  Widget _buildQuestionRow(String question, int index) {
    return Container(
      margin: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.lightPurpleColor,
        borderRadius: BorderRadius.circular(50.0),
      ),
      padding: EdgeInsets.all(15.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: Text(
                question,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19.sp,
                  color: Colors.white,
                  fontFamily: 'Rubik',
                ),
              ),
            ),
          ),
          if (_isSavedList[index])
            const Icon(Icons.check_circle, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildAnswerForm(int index, bool answered, String question) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        children: [
          TextFormField(
            style: Styles.bodyTextStyle,
            focusNode: _justFocusNode,
            maxLines: 5,
            maxLength: 96,
            controller: _isControllers[index],
            onTap: () {
              if (_justFocusNode.hasFocus) {
                _justFocusNode.unfocus();
              }
            },
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.purpleColor,
                  width: 2.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(
                  color: AppColors.purpleColor,
                  width: 2.0,
                ),
              ),
              border: const OutlineInputBorder(),
              counterStyle: const TextStyle(
                color: AppColors.whiteColor,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          _buildSaveButton(index, answered, question)
        ],
      ),
    );
  }

  Widget _buildSaveButton(int index, bool answered, String question) {
    return Container(
      alignment: Alignment.centerRight,
      child: MyElevatedButton(
        height: 50.h,
        width: 150.w,
        onPressed: () {
          if (_isControllers[index].text.isNotEmpty) {
            answers[question] = _isControllers[index].text;
            if (!answered) {
              setState(() => currentAnswers++);
            }
            setState(() {
              _justFocusNode.unfocus();
              _isSavedList[index] = true;
              _isExpandedList[index] = !_isExpandedList[index];
            });
          }
        },
        child: Text(
          'Tallenna',
          style: TextStyle(
            fontSize: 19.sp,
            color: Colors.white,
            fontFamily: 'Rubik',
          ),
        ),
      ),
    );
  }
}
