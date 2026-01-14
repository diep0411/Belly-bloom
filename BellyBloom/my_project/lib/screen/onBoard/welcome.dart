import 'package:flutter/material.dart';
import 'package:my_project/resoucre/ColorManager.dart';
import 'package:my_project/resoucre/image_manager.dart';
import 'package:my_project/model/welcome_model.dart';
import 'package:my_project/resoucre/reponsive_utils.dart';
import 'package:my_project/screen/login_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  List<WelcomeModel> listWelcome = [
    WelcomeModel(
      title: 'Thong so',
      imageUrl: ImageRes.welcome1,
      subtitle: 'Welcome1',
      content:
          'Manage your tasks, set reminders, and stay organized with our app.',
    ),
    WelcomeModel(
      title: 'Bump Baby',
      imageUrl: ImageRes.welcome1,
      subtitle: 'Welcome2',
      content:
          'Manage your tasks, set reminders, and stay organized with our app.',
    ),
    WelcomeModel(
      title: 'Bump Baby',
      imageUrl: ImageRes.welcome1,
      subtitle: 'Welcome3',
      content:
          'Manage your tasks, set reminders, and stay organized with our app.',
    ),
  ];
  int currentIndex = 0;
  PageController controller = PageController();

  void jumpnextpage() {
    if (currentIndex < listWelcome.length - 1) {
      controller.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.linear,
      );
      setState(() {
        currentIndex = currentIndex + 1;
      });
    }
  }

  void jumpbackpage() {
    if (currentIndex != 0) {
      controller.previousPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.linear,
      );
      setState(() {
        currentIndex = currentIndex - 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: UtilsReponsive.padding(context, horizontal: 40),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  ),
                },
                child: Text(
                  'SKIP',
                  style: TextStyle(
                    color: managerColor.primary,
                    fontSize: UtilsReponsive.formatFontSize(17, context),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: listWelcome.length,
                itemBuilder: (context, index) {
                  return _cardWelcome(
                    context,
                    model: listWelcome[index],
                    isFinal: index == listWelcome.length - 1,
                  );
                },
              ),
            ),
            if (currentIndex != listWelcome.length - 1) _controlPage(context),
          ],
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
            onTap: () => {
              if (currentIndex != 0) {jumpbackpage()},
            },
            child: SizedBox(
              width: 40,
              child: Text(currentIndex == 0 ? '' : 'BACK'),
            ),
          ),
          Expanded(
            child: Center(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: listWelcome.length,
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) =>
                    SizedBox(width: UtilsReponsive.width(10, context)),
                itemBuilder: (context, index) => Container(
                  height: UtilsReponsive.height(20, context),
                  width: UtilsReponsive.width(20, context),
                  decoration: BoxDecoration(
                    color: index == currentIndex
                        ? managerColor.primary
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: managerColor.grey, width: 1),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(onTap: () => {jumpnextpage()}, child: Text('NEXT')),
        ],
      ),
    );
  }

  Column _cardWelcome(
    BuildContext context, {
    required WelcomeModel model,
    bool isFinal = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            text: model.title.split(' ')[0],
            style: TextStyle(
              fontSize: UtilsReponsive.formatFontSize(32, context),
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: ' ${model.title.split(' ')[1]}',
                style: TextStyle(
                  fontSize: UtilsReponsive.formatFontSize(32, context),
                  color: managerColor.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBoxConst.size(context: context, size: 20),
        Image.asset(model.imageUrl),
        SizedBoxConst.size(context: context, size: 40),
        if (model.subtitle != null)
          Text(
            model.subtitle!,
            style: TextStyle(
              color: managerColor.primary,
              fontSize: UtilsReponsive.formatFontSize(30, context),
              fontWeight: FontWeight.bold,
            ),
          ),
        SizedBox(height: 10),
        Text(model.content, textAlign: TextAlign.center),
        if (isFinal)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Text('Get Started'),
          ),
      ],
    );
  }
}
