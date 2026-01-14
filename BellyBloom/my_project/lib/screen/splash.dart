import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_project/resoucre/ColorManager.dart';
import 'package:my_project/resoucre/image_manager.dart';
import 'package:my_project/screen/form_collection/form_collection.dart';
import 'package:my_project/screen/home_page.dart';
import 'package:my_project/screen/login_page.dart';
import 'package:my_project/service/base_common.dart';
import 'package:my_project/service/notification_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    log('initState');
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 2)).then((v) {
      BaseCommon().checkLogin().then((accountValue) {
        if (accountValue == null) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => LoginPage()));
        } else {
          BaseCommon().saveUserAccount(accountValue);
          // Reschedule notifications after login
          NotificationService.rescheduleAllAppointments();
          if (accountValue.formCollection == null) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => FormCollectionPage()));
          } else {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => HomePage()));
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: managerColor.primary,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(ImageRes.logo),
          Text(
            'Belly Bloom',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }
}
