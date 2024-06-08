import '/utilities/app_routes.dart';
import '/firebase/firebase_queries.dart';

import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  final firebaseQueries = Get.put(FirebaseQueries());

  startTimer(int seconds){
    Timer(Duration(seconds: seconds), () async {
      if(firebaseQueries.getCurrentUser() == null) {
        Get.offNamed(AppRoutes.getLoginRoute());
      } else {
        Get.offNamed(AppRoutes.getMainRoute());
      }
    });
  }

  @override
  void initState() {
    super.initState();

    startTimer(3);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(

        //Background
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/appletree_logo.png",
                height: 150.0,
                width: 150.0,
              ),

              const SizedBox(height: 30,),

              const CircularProgressIndicator( color: Colors.primary_light,),
            ],
          ),
        ),
      ),
    );
  }
}
