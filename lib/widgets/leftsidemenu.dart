import '/utilities/app_routes.dart';
import '/utilities/variables.dart';

import '/firebase/firebase_queries.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';


class LeftsideMenu extends StatefulWidget{
  const LeftsideMenu({Key? key}) : super(key: key);

  @override
  State<LeftsideMenu> createState() => _LeftsideMenu();
}

class _LeftsideMenu extends State<LeftsideMenu> {

  @override
  Widget build(BuildContext context) {

    final firebaseQueries = Get.put(FirebaseQueries());   

    //FUNCTIONS//

    logout() {
      currentScreen = "main";
      firebaseQueries.logout();
      Get.offAllNamed(AppRoutes.getLoginRoute());
    }

    goToQuizes() {
      currentScreen = "quizes";
      Get.toNamed(AppRoutes.getQuizesRoute());
    }

    goToTasks() {
      currentScreen = "tasks";
      Get.toNamed(AppRoutes.getTasksRoute());
    }

    goToMessages() {
      currentScreen = "messages";
      Get.toNamed(AppRoutes.getMessagesRoute());
    }

    goToFollowup() {
      currentScreen = "followup";
      Get.toNamed(AppRoutes.getFollowupRoute());
    }

    goToSettings() {
      currentScreen = "settings";
      Get.toNamed(AppRoutes.getSettingsRoute());
    }

    //END OF FUNCTIONS//

    return Container(
      height: double.infinity,
      //width: 110,
      color: Colors.primary_dark,
      child: Column(children: [
        //user
        Container(
          width: 110,
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Colors.primary_light,
                width: 1,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                top: 10, bottom: 5, right: 3, left: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //username
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                //logout button
                TextButton.icon(
                    onPressed: () {
                      logout();
                    },
                    icon: const Icon(
                      Icons.power_settings_new,
                      color: Colors.white,
                      size: 10,
                    ),
                    label: const Text(
                      "Cerrar sesión",
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    style: TextButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        side:
                        BorderSide(color: Colors.transparent, width: 2),
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.only(right: 5, left: 5),
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 14),
                    )),
              ],
            ),
          ),
        ),

        //buttons in side menu
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 0,
              width: 110,
              child: Divider(
                height: 10,
                thickness: 1,
                color: Colors.primary_light,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                shape: LinearBorder(
                  side: BorderSide(
                      color:
                      currentScreen == "quizes"
                          ? Colors.greenAccent
                          : Colors.transparent,
                      width: 2
                  ),
                  end: const LinearBorderEdge(),
                ),
                padding: const EdgeInsets.only(
                    top: 20, bottom: 20, right: 65, left: 10),
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 14),
              ),
              onPressed: () {
                goToQuizes();
              },
              child: const Text("Tests"),
            ),
            const SizedBox(
              height: 0,
              width: 110,
              child: Divider(
                height: 10,
                thickness: 1,
                color: Colors.primary_light,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                shape: LinearBorder(
                  side: BorderSide(
                      color:
                      currentScreen == "tasks"
                      ? Colors.greenAccent
                      : Colors.transparent,
                      width: 2
                  ),
                  end: const LinearBorderEdge(),
                ),
                padding: const EdgeInsets.only(
                    top: 20, bottom: 20, right: 57, left: 10),
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 14),
              ),
              onPressed: () {
                goToTasks();
              },
              child: const Text("Tareas"),
            ),
            const SizedBox(
              height: 0,
              width: 110,
              child: Divider(
                height: 10,
                thickness: 1,
                color: Colors.primary_light,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                shape: LinearBorder(
                  side: BorderSide(
                    color:
                    currentScreen == "messages"
                    ? Colors.greenAccent
                    : Colors.transparent,
                    width: 2
                  ),
                  end: const LinearBorderEdge(),
                ),
                padding: const EdgeInsets.only(
                    top: 20, bottom: 20, right: 39, left: 10),
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 14),
              ),
              onPressed: () {
                goToMessages();
              },
              child: const Text("Mensajes"),
            ),
            const SizedBox(
              height: 0,
              width: 110,
              child: Divider(
                height: 10,
                thickness: 1,
                color: Colors.primary_light,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                shape: LinearBorder(
                  side: BorderSide(
                      color:
                      currentScreen == "followup"
                      ? Colors.greenAccent
                      : Colors.transparent,
                      width: 2
                  ),
                  end: const LinearBorderEdge(),
                ),
                padding: const EdgeInsets.only(
                    top: 20, bottom: 20, right: 22, left: 10),
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 14),
              ),
              onPressed: () {
                goToFollowup();
              },
              child: const Text("Seguimiento"),
            ),
            const SizedBox(
              height: 0,
              width: 110,
              child: Divider(
                height: 10,
                thickness: 1,
                color: Colors.primary_light,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                shape: LinearBorder(
                  side: BorderSide(
                    color:
                    currentScreen == "settings"
                    ? Colors.greenAccent
                        : Colors.transparent,
                    width: 2
                  ),
                  end: const LinearBorderEdge(),
                ),
                padding: const EdgeInsets.only(
                    top: 20, bottom: 20, right: 53, left: 10),
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 14),
              ),
              onPressed: () {
                goToSettings();
              },
              child: const Text("Ajustes"),
            ),
            const SizedBox(
              height: 0,
              width: 110,
              child: Divider(
                height: 10,
                thickness: 1,
                color: Colors.primary_light,
              ),
            ),
          ],
        ),
      ]),
    );
  }
}