import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:miitti_app/constants/constants.dart';

import 'package:miitti_app/constants/constants_customButton.dart';
import 'package:miitti_app/constants/constants_customTextField.dart';
import 'package:miitti_app/constants/constants_onboarding.dart';
import 'package:miitti_app/constants/constants_styles.dart';
import 'package:miitti_app/constants/constants_widgets.dart';
import 'package:miitti_app/constants/miittiUser.dart';
import 'package:miitti_app/helpers/activity.dart';
import 'package:miitti_app/index_page.dart';
import 'package:miitti_app/login/completeProfile/completeProfile_answerPage.dart';
import 'package:miitti_app/provider/auth_provider.dart';

import 'package:miitti_app/utils/utils.dart';
import 'package:provider/provider.dart';

class CompleteProfileOnboard extends StatefulWidget {
  const CompleteProfileOnboard({super.key});

  @override
  State<CompleteProfileOnboard> createState() => _CompleteProfileOnboard();
}

class _CompleteProfileOnboard extends State<CompleteProfileOnboard> {
  late PageController _pageController;

  File? myImage;

  late List<TextEditingController> _formControllers;

  final List<ConstantsOnboarding> onboardingScreens = [
    ConstantsOnboarding(
      title: 'Aloitetaan,\nmikä on etunimesi?',
      warningText:
          'Olet uniikki, muistathan siis käyttää vain omia henkilötietoja!',
      hintText: 'Syötä etunimesi',
      keyboardType: TextInputType.name,
    ),
    ConstantsOnboarding(
      title: 'Lisää aktiivinen sähköpostiosoite',
      warningText:
          'Emme käytä sähköpostiasi koskaan markkinointiin ilman lupaasi!',
      hintText: 'Syötä sähköpostiosoitteesi',
      keyboardType: TextInputType.emailAddress,
    ),
    ConstantsOnboarding(
      title: 'Kerro meille syntymäpäiväsi',
      warningText: 'Laskemme tämän perusteella ikäsi',
    ),
    ConstantsOnboarding(
      title: 'Mikä sukupuoli\nkuvaa sinua parhaiten',
      warningText:
          'Sukupuoli ei määrittele sinua, mutta sen avulla voimme tarjota entistä paremmin miittejä juuri sinulle!',
    ),
    ConstantsOnboarding(
      title: 'Puhun jotain seuraavista kielistä',
      warningText:
          'Valitse enintään neljä kieltä, joilla voit kommunikoida muiden kanssa.',
    ),
    ConstantsOnboarding(
      title: 'Valitse paikkakunta',
      warningText:
          'Valitse enintään kaksi paikkakuntaa, jossa oleskelet. Jos asuinpaikkakuntasi puuttuu listalta valitse “Muu Suomi”',
      isFullView: true,
    ),
    ConstantsOnboarding(
      title: 'Mikä on elämäntilanteesi?',
      warningText: 'Näin osaamme yhdistää sinut paremmin uusiin tuttavuuksiin',
    ),
    ConstantsOnboarding(
      title: 'Kerro itsestäsi',
      warningText: 'Valitse 1-10 Q&A -avausta, johon haluat vastata',
      isFullView: true,
    ),
    ConstantsOnboarding(
      title: 'Lisää profiilikuva',
      warningText:
          'Lisää profiilikuva, joka kuvastaa persoonaasi parhaiten! Huomioithan, että sinun tulee näkyä itse kuvassa, eikä se saa olla tekoälyn tuottama.',
      isFullView: true,
    ),
    ConstantsOnboarding(
      title: 'Mitä tykkäät tehdä?',
      warningText:
          'Valitse enintään yhdeksän lempiaktiviteettia, joista pidät!',
      isFullView: true,
    ),
    ConstantsOnboarding(
      title: 'Vielä lopuksi!',
      warningText:
          'Jokainen yhteisö tarvitsee sääntöjä. Tässä keskeisimmät yhteisönormimme, joita odotamme sinun noudattavan:',
      isFullView: true,
    ),
  ];

  //PAGE 1 NAME

  //PAGE 2 EMAIL

  //PAGE 3 BDAY
  String birthdayText = 'DDMMYYYY';
  String editiedVersionOfBirthdayText = "";

  //PAGE 4 GENDER
  final List<String> genders = ['Mies', 'Nainen', 'Ei-binäärinen'];
  String selectedGender = '';

  //PAGE 5 PICK LANGUAGES
  final List<String> languages = [
    'Suomi',
    'Englanti',
    'Ruotsi',
    'Viro',
    'Venäjä',
    'Arabia',
    'Saksa',
    'Ranska',
    'Espanja',
    'Kiina',
  ];
  Set<String> selectedLanguages = {};

  //PAGE 6 LIFE SITUATION
  bool noLifeSituation = false;
  final List<String> lifeOptions = [
    'Opiskelija',
    'Työelämässä',
    'Yrittäjä',
    'Etsimässä itseään',
  ];

  String selectedLifeOption = '';

  //PAGE 7 CITY
  final List<String> cities = [
    'Helsinki',
    'Espoo',
    'Vantaa',
    'Kauniainen',
    'Turku',
    'Tampere',
    'Oulu',
    'Jyväskylä',
    'Lappeenranta',
    'Muu Suomi',
  ];
  Set<String> selectedCities = {};

  //PAGE 8 Q&A
  final List<String> questionsAboutMe = [
    'Kuvailen itseäni näillä viidellä emojilla',
    'Persoonaani kuvaa parhaiten se, että',
    'Fakta, jota useimmat minusta eivät tiedä',
    'Olen uusien ihmisten seurassa yleensä',
    'Erikoisin taito, jonka osaan',
    'Lempiruokani on ehdottomasti',
    'En voisi elää ilman',
    'Olen miestäni',
    'Ottaisin mukaan autiolle saarelle',
    'Suosikkiartistini on',
    'Arvostan eniten ihmisiä, jotka',
    'Ylivoimainen inhokkiruokani on',
  ];
  final List<String> questionsAboutHobbies = [
    'Lempiharrastukseni on',
    'Käytän vapaa-päiväni useimmiten',
    'Haluaisin kokeilla',
    'Harrastin lapsena ',
    'Harrastus, jota en ole vielä uskaltanut kokeilla',
    'Haluaisin löytää',
    'Haluaisin matkustaa seuraavaksi',
    'Paras matkavinkkini on',
  ];
  final List<String> questionsAboutDeep = [
    'Koen olevani',
    'Pahin pakkomielteeni on',
    'Suurin vahvuuteni on',
    'En ole parhaimmillani',
    'Kiusallisin hetkeni oli, kun',
    'Olin viimeksi surullinen, koska',
    'En ole koskaan sanonut, että',
    'Olen otettu, jos',
    'Ottaisin mukaan autiolle saarelle',
    'Olen onnellinen, koska',
    'Tänä vuonna haluan',
  ];

  List<String> selectedList = [];

  int answerLimit = 10;
  int currentAnswers = 0;
  Map<String, String> userChoices = {};

  //PAGE 9 PICTURE
  File? image;

  //PAGE 10 ACTIVITIES
  Set<String> favoriteActivities = <String>{};

  //PAGE 11 RULES
  List<String> miittiRules = <String>[
    'Käyttäydyn muita ihmisiä kohtaan ystävällisesti ja kunnioittavasti',
    'Esiinnyn sovelluksessa omana itsenäni, enkä käytä muiden kuvia tai henkilötietoja.',
    'Ymmärrän, että Miitti App ei ole deittipalvelu. Lähestyn sovelluksessa muita ihmisiä ainoastaan kaverimielessä.',
    'En harjoita tai kannusta harjoittamaan lain vastaista toimintaa sovelluksen avulla',
  ];
  List<String> userAcceptedRules = <String>[];
  bool warningSignVisible = false;

  @override
  void initState() {
    super.initState();
    selectedList = questionsAboutMe;
    _formControllers = List.generate(
        onboardingScreens.length - 1, (_) => TextEditingController());
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _formControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> selectImage({required bool isCamera}) async {
    ConstantsWidgets().showLoadingDialog(context);

    image = isCamera
        ? await pickImageFromCamera(context)
        : await pickImage(context);

    if (context.mounted) {
      Navigator.pop(context);
    }
    setState(() {});
  }

  Widget mainWidgetsForScreens(int page) {
    ConstantsOnboarding screen = onboardingScreens[page];
    switch (page) {
      case 2:
        return Row(
          children: [
            for (int i = 0; i <= 7; i++)
              GestureDetector(
                onTap: () => pickBirthdayDate(
                  context: context,
                  onDateTimeChanged: (dateTime) {
                    setState(() {
                      editiedVersionOfBirthdayText =
                          '${dateTime.month}/${dateTime.day}/${dateTime.year}';
                      birthdayText =
                          '${dateTime.day.toString().padLeft(2, '0')}${dateTime.month.toString().padLeft(2, '0')}${dateTime.year}';
                    });
                  },
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(152, 28, 228, 0.10),
                    border: Border(
                      bottom: BorderSide(width: 1.0, color: Colors.white),
                    ),
                  ),
                  margin: EdgeInsets.only(
                    right: (i == 1 || i == 3)
                        ? i == 7
                            ? 0.w
                            : 18.w
                        : 7.w,
                  ),
                  padding: EdgeInsets.all(10.w),
                  child: Center(
                    child: Text(
                      birthdayText[i],
                      style: ConstantStyles.body.copyWith(
                        color: Colors.white.withOpacity(
                          birthdayText == "DDMMYYYY" ? 0.5 : 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (String gender in genders)
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedGender = gender;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 15.h),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A1026),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: selectedGender == gender
                          ? ConstantStyles.pink
                          : Colors.transparent,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    'Olen $gender',
                    style: ConstantStyles.warning,
                  ),
                ),
              ),
          ],
        );
      case 4:
        return Wrap(
          children: [
            for (String language in languages)
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (!selectedLanguages.contains(language) &&
                        selectedLanguages.length < 4) {
                      selectedLanguages.add(language);
                    } else {
                      selectedLanguages.remove(language);
                    }
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 15.w, bottom: 15.h),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A1026),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: selectedLanguages.contains(language)
                          ? ConstantStyles.pink
                          : Colors.transparent,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    language,
                    style: ConstantStyles.warning,
                  ),
                ),
              ),
          ],
        );
      case 5:
        return Expanded(
          child: ListView.builder(
            itemCount: cities.length,
            itemBuilder: (context, index) {
              String city = cities[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (!selectedCities.contains(city) &&
                        selectedCities.length <= 1) {
                      selectedCities.add(city);
                    } else {
                      selectedCities.remove(city);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(224, 84, 148, 0.05),
                    border: Border.all(
                      color: selectedCities.contains(city)
                          ? ConstantStyles.pink
                          : Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    city,
                    style: ConstantStyles.body,
                  ),
                ),
              );
            },
          ),
        );

      case 6:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220.h,
              child: ListView.builder(
                itemCount: lifeOptions.length,
                itemBuilder: (context, index) {
                  String option = lifeOptions[index];
                  return GestureDetector(
                    onTap: () {
                      if (!noLifeSituation) {
                        setState(() {
                          selectedLifeOption = option;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      margin: EdgeInsets.only(bottom: 8.h),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(224, 84, 148, 0.05),
                        border: Border.all(
                          color: selectedLifeOption == option
                              ? ConstantStyles.pink
                              : Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        option,
                        style: ConstantStyles.body,
                      ),
                    ),
                  );
                },
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CupertinoSwitch(
                activeColor: ConstantStyles.pink,
                value: noLifeSituation,
                onChanged: (bool value) {
                  setState(() {
                    selectedLifeOption = "";
                    noLifeSituation = value;
                  });
                },
              ),
              title: Text(
                'Jätän tämän tyhjäksi',
                style: ConstantStyles.hintText.copyWith(
                    fontWeight: FontWeight.w500,
                    color: noLifeSituation
                        ? Colors.white
                        : const Color.fromRGBO(255, 255, 255, 0.20)),
              ),
            )
          ],
        );
      case 7:
        return Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedList = questionsAboutMe;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10.w, bottom: 10.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1026),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: selectedList == questionsAboutMe
                            ? ConstantStyles.pink
                            : Colors.transparent,
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      'Enemmän minusta',
                      style: ConstantStyles.warning,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedList = questionsAboutHobbies;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10.w, bottom: 10.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1026),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: selectedList == questionsAboutHobbies
                            ? ConstantStyles.pink
                            : Colors.transparent,
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      'Harrastukset',
                      style: ConstantStyles.warning,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedList = questionsAboutDeep;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10.w, bottom: 10.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1026),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: selectedList == questionsAboutDeep
                            ? ConstantStyles.pink
                            : Colors.transparent,
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      'Syvälliset',
                      style: ConstantStyles.warning,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 500.h,
              child: ListView.builder(
                itemCount: selectedList.length,
                itemBuilder: (context, index) {
                  String question = selectedList[index];
                  return GestureDetector(
                    onTap: () async {
                      String? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CompleteProfileAnswerPage(
                            question: question,
                            questionAnswer: null,
                          ),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          if (result != "") {
                            userChoices[question] = result;
                          } else {
                            userChoices.remove(question);
                          }
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1.0,
                            color: Color.fromRGBO(224, 84, 148, 0.20),
                          ),
                          top: BorderSide(
                            width: 1.0,
                            color: Color.fromRGBO(224, 84, 148, 0.20),
                          ),
                        ),
                      ),
                      child: Text(
                        question,
                        style: ConstantStyles.question.copyWith(
                          color: Colors.white.withOpacity(
                            userChoices.containsKey(question) ? 0.5 : 1.0,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      case 8:
        return Expanded(
          child: Column(
            children: [
              image != null
                  ? SizedBox(
                      height: 350.h,
                      width: 350.w,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          image!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Container(
                      height: 350.h,
                      width: 350.w,
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(250, 250, 253, 0.10),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Center(
                        child: Text(
                          'Ei lisättyjä kuvia',
                          style: ConstantStyles.body.copyWith(fontSize: 24.sp),
                        ),
                      ),
                    ),
              ConstantStyles().gapH10,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      selectImage(isCamera: false);
                    },
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(250, 250, 253, 0.05),
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.image_search_rounded,
                            color: Colors.white,
                          ),
                          ConstantStyles().gapW5,
                          Text(
                            'Lisää uusi kuva',
                            style:
                                ConstantStyles.body.copyWith(fontSize: 16.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      selectImage(isCamera: true);
                    },
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(250, 250, 253, 0.05),
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.photo_camera_rounded,
                            color: Colors.white,
                          ),
                          ConstantStyles().gapW5,
                          Text(
                            'Ota uusi kuva',
                            style:
                                ConstantStyles.body.copyWith(fontSize: 16.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      case 9:
        return Expanded(
          child: GridView.builder(
            itemCount: activities.keys.toList().length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 10.0,
            ),
            itemBuilder: (context, index) {
              final activity = activities.keys.toList()[index];
              final isSelected = favoriteActivities.contains(activity);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (favoriteActivities.contains(activity)) {
                      favoriteActivities.remove(activity);
                    } else {
                      if (favoriteActivities.length < 9) {
                        favoriteActivities.add(activity);
                      }
                    }
                  });
                },
                child: Container(
                  width: 100.w,
                  padding: EdgeInsets.symmetric(
                    vertical: 10.h,
                    horizontal: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? ConstantStyles.pink : Colors.transparent,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    border: Border.all(color: ConstantStyles.pink),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        Activity.getActivity(activity).emojiData,
                        style: ConstantStyles.title,
                      ),
                      Text(
                        Activity.getActivity(activity).name,
                        overflow: TextOverflow.ellipsis,
                        style: ConstantStyles.warning.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );

      case 10:
        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (String rule in miittiRules)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (userAcceptedRules.contains(rule)) {
                        userAcceptedRules.remove(rule);
                      } else {
                        userAcceptedRules.add(rule);
                      }
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 15.h),
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1026),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: userAcceptedRules.contains(rule)
                            ? ConstantStyles.pink
                            : Colors.transparent,
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      rule,
                      style: ConstantStyles.warning,
                    ),
                  ),
                ),
              const Spacer(),
              warningSignVisible
                  ? Text(
                      'Sinun täytyy klikata kaikki kohdat hyväksytyksi jatkaaksesi!',
                      style: ConstantStyles.warning.copyWith(
                        color: ConstantStyles.red,
                      ),
                    )
                  : Container()
            ],
          ),
        );

      default:
        {
          return ConstantsCustomTextField(
            hintText: screen.hintText!,
            controller: _formControllers[page],
            keyboardType: screen.keyboardType,
          );
        }
    }
  }

  Future<void> registerUser(BuildContext context, MiittiUser user) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    if (ap.isAnonymous) {
      ap
          .updateUserInfo(
            updatedUser: user,
            imageFile: image,
            context: context,
          )
          .then(
            (value) => ap.saveUserDataToSP().then(
                  (value) => ap.setSignIn().then(
                        (value) => ap.setAnonymousModeOf().then(
                              (value) => pushNRemoveUntil(
                                context,
                                IndexPage(),
                              ),
                            ),
                      ),
                ),
          );
    } else {
      ap.saveUserDatatoFirebase(
        context: context,
        userModel: user,
        image: image,
        onSucess: () {
          ap.saveUserDataToSP().then(
                (value) => ap.setSignIn().then(
                  (value) {
                    pushNRemoveUntil(context, IndexPage());
                  },
                ),
              );
        },
      );
    }
  }

  void errorHandlingScreens(int page) {
    final currentPage = _pageController.page!.toInt();

    switch (currentPage) {
      case 0:
        if (_formControllers[0].text.isEmpty) {
          showSnackBar(
            context,
            'Kysymys "${onboardingScreens[0].title}" ei voi olla tyhjä!',
            ConstantStyles.red,
          );
          return;
        }
        break;
      case 1:
        if (!EmailValidator.validate(_formControllers[1].text)) {
          showSnackBar(
            context,
            'Sähköposti on tyhjä tai se on väärä sähköposti!!',
            ConstantStyles.red,
          );
          return;
        }
        break;
      case 2:
        if (birthdayText == 'DDMMYYYY') {
          showSnackBar(
            context,
            'Kysymys "${onboardingScreens[2].title}" ei voi olla tyhjä!',
            ConstantStyles.red,
          );
          return;
        }
        break;
      case 3:
        if (selectedGender.isEmpty) {
          showSnackBar(
            context,
            'Kysymys "${onboardingScreens[3].title}" ei voi olla tyhjä!',
            ConstantStyles.red,
          );
          return;
        }
      case 4:
        if (selectedLanguages.isEmpty || selectedLanguages.length > 4) {
          showSnackBar(
            context,
            'Valitse vähintään 1 ja enintään 4 kieltä!',
            ConstantStyles.red,
          );
          return;
        }
      case 5:
        if (selectedCities.isEmpty && selectedCities.length <= 1) {
          showSnackBar(
            context,
            'Valitse vähintään 1 ja enintään 2 paikkakuntaa!',
            ConstantStyles.red,
          );
          return;
        }
      case 6:
        if (selectedLifeOption.isEmpty && noLifeSituation == false) {
          showSnackBar(
            context,
            'Valitse  1 elämäntilanteesi tai jätä sen tyhjäksi!',
            ConstantStyles.red,
          );
          return;
        }

      case 7:
        if (userChoices.isEmpty) {
          showSnackBar(
            context,
            'Valitse 1-10 Q&A -avausta, johon haluat vastata',
            ConstantStyles.red,
          );
          return;
        }
      case 8:
        if (image == null) {
          showSnackBar(
            context,
            'Profiilikuva ei voi olla tyhjä!',
            ConstantStyles.red,
          );
          return;
        }
      case 9:
        if (favoriteActivities.isEmpty || favoriteActivities.length > 9) {
          showSnackBar(
            context,
            'Valitse lempiaktiviteettia, joista pidät!',
            ConstantStyles.red,
          );
          return;
        }
      case 10:
        if (userAcceptedRules.length != miittiRules.length) {
          setState(() {
            warningSignVisible = true;
          });
          return;
        }
    }

    if (page != 9) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.linear,
      );
    } else {
      print("BURAYA GELDINIZ");
      MiittiUser miittiUser = MiittiUser(
        userName: _formControllers[0].text.trim(),
        userEmail: _formControllers[1].text.trim(),
        uid: '',
        userPhoneNumber: '',
        userBirthday: editiedVersionOfBirthdayText,
        userArea: selectedCities.join(","),
        userFavoriteActivities: favoriteActivities,
        userChoices: userChoices,
        userGender: selectedGender,
        userLanguages: selectedLanguages,
        profilePicture: '',
        invitedActivities: {},
        userStatus: '',
        userSchool: noLifeSituation ? '' : selectedLifeOption,
        fcmToken: '',
        userRegistrationDate: DateFormat('dd/MM/yyyy').format(DateTime.now()),
      );
      registerUser(context, miittiUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingScreens.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  ConstantsOnboarding screen = onboardingScreens[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        screen.isFullView == true
                            ? ConstantStyles().gapH10
                            : const Spacer(),
                        Text(
                          screen.title,
                          style: ConstantStyles.title,
                        ),
                        Text(
                          screen.warningText,
                          style: ConstantStyles.warning,
                        ),
                        ConstantStyles().gapH20,
                        mainWidgetsForScreens(index),

                        screen.isFullView == true
                            ? ConstantStyles().gapH10
                            : const Spacer(),
                        ConstantsCustomButton(
                          buttonText: screen.title == 'Vielä lopuksi!'
                              ? 'Hyväksyn yhteisönormit'
                              : 'Seuraava',
                          onPressed: () => errorHandlingScreens(index),
                        ), //Removed extra padding in ConstantsCustomButton
                        ConstantStyles().gapH10,
                        ConstantsCustomButton(
                          buttonText: 'Takaisin',
                          isWhiteButton: true,
                          onPressed: () {
                            if (_pageController.page != 0) {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.linear,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
