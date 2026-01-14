import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_project/model/form_collection.dart';
import 'package:my_project/resoucre/ColorManager.dart';
import 'package:my_project/resoucre/reponsive_utils.dart';
import 'package:my_project/screen/Home_page.dart';
import 'package:my_project/screen/form_collection/collectioncalender.dart';
import 'package:my_project/screen/form_collection/collectionheight.dart';
import 'package:my_project/screen/form_collection/collectionweight.dart';
import 'package:my_project/screen/tab/form_collection_title.dart';
import 'package:my_project/service/account_service.dart';
import 'package:my_project/service/base_common.dart';
import 'package:my_project/utils/util_common.dart';

class FormCollectionPage extends StatefulWidget {
  const FormCollectionPage({super.key});

  @override
  State<FormCollectionPage> createState() => _FormCollectionPageState();
}

class _FormCollectionPageState extends State<FormCollectionPage> {
  List<FormCollectionTitle> listWelcome = [];
  int currentIndex = 0;

  PageController controller = PageController(keepPage: true);

  double heightData = 170;
  int weightData = 59;
  int weekData = 2;

  void getHeight(double height) {
    log('getHeight: $height');
    heightData = height;
  }

  void getWeight(int weight) {
    log('getWeight: $weight');
    weightData = weight;
  }

  void getWeek(int week) {
    log('getWeek: $week');
    weekData = week;
  }

  void jumpNextPage() {
    // controller.jumpToPage(index + 1);
    if (currentIndex < listWelcome.length - 1) {
      controller.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.linear,
      );
    }
  }

  void jumpBack() {
    // controller.jumpToPage(index + 1);
    if (currentIndex != 0) {
      controller.previousPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.linear,
      );
    }
  }

  void submitData() async {
    FormCollection formCollection = FormCollection(
      id: 1,
      height: heightData,
      weight: weightData,
      week: weekData,
      createdAt: DateTime.now(),
      lastestUpdate: DateTime.now(),
    );
    // log('formCollection: ${jsonEncode(formCollection)}');
    // log('user_uid: ${prefs.getString('user_uid')}');
    final userUid = BaseCommon().userAccount.uid;

    AccountService.updateUserCollectionForm(
      formCollection: formCollection,
      uid: userUid ?? '',
    );
    BaseCommon().saveUserAccount(
      BaseCommon().userAccount.copyWith(formCollection: formCollection),
    );
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => HomePage()));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState

    listWelcome = [
      FormCollectionTitle(
        id: 1,
        title: 'Chiều cao của bạn là bao nhiêu?',
        content:
            'Việc biết thông tin chiều cao sẽ giúp chúng tôi cải thiện và đưa ra gợi ý phù hợp cho bé.',
        widget: CollectionHeightWidget(
          getHeight: getHeight,
          initalizeHeight: heightData,
        ),
      ),
      FormCollectionTitle(
        id: 1,
        title: 'Trang thông số',
        content: 'Trang thông số',
        widget: CollectionWeightWidget(
          getWeight: getWeight,
          initalizeWeight: weightData,
        ),
      ),
      FormCollectionTitle(
        id: 1,
        title: 'Tuần thai kì hiên tại của bạn',
        content: 'Tuần thai kì hiên tại của bạn là bao nhiêu?',
        widget: CollectioncalenderWidget(
          calculateDueDate: UtilsCommon.calculateDueDate,
          inteializeWeek: weekData,
          getWeek: getWeek,
        ),
      ),
    ];
    super.initState();
  }

  // void calculateDueDate(DateTime currentDate, int currentWeek) {
  //   const totalWeeks = 40;
  //   int weeksRemaining = totalWeeks - currentWeek;
  //   final data = currentDate.add(Duration(days: weeksRemaining * 7));
  //   log('Ngày dự sinh: $data');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:
          currentIndex == listWelcome.length - 1
              ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: managerColor.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  submitData();
                  // Navigator.of(
                  //   context,
                  // ).push(MaterialPageRoute(builder: (_) => HomePage()));
                },
                child: Text('Hoàn thành'),
              )
              : SizedBox(),
      body: SafeArea(
        child: Padding(
          padding: UtilsReponsive.padding(context, horizontal: 40),
          child: Column(
            children: [
              Visibility(
                visible: currentIndex != listWelcome.length - 1,
                maintainState: true,
                maintainAnimation: true,
                maintainSize: true,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Skip',
                    style: TextStyle(color: managerColor.primary),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  controller: controller,
                  itemCount: listWelcome.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    // log('Index: ${listWelcome[index].title}');
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          listWelcome[index].title,
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(
                              32,
                              context,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          listWelcome[index].content,
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(
                              22,
                              context,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(child: listWelcome[index].widget),
                      ],
                    );
                  },
                ),
              ),
              Visibility(
                visible: currentIndex != listWelcome.length - 1,
                maintainState: true,
                maintainAnimation: true,
                maintainSize: true,
                child: _controlPage(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox _controlPage(BuildContext context) {
    return SizedBox(
      height: UtilsReponsive.height(80, context),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              jumpBack();
            },
            child: SizedBox(
              width: 40,
              child: currentIndex != 0 ? Text('Back') : SizedBox(),
            ),
          ),
          Expanded(
            child: Center(
              child: ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: listWelcome.length,
                separatorBuilder: (context, index) => SizedBox(width: 10),
                itemBuilder:
                    (context, index) => Container(
                      height: UtilsReponsive.height(20, context),
                      width: UtilsReponsive.height(20, context),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        color:
                            index == currentIndex
                                ? managerColor.primary
                                : Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              jumpNextPage();
            },
            child: SizedBox(width: 40, child: Text('Next')),
          ),
        ],
      ),
    );
  }
}
