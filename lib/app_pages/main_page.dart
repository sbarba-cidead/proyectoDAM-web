import 'package:appletreeweb/firebase/firebase_queries.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '/utilities/variables.dart';
import '/widgets/leftsidemenu.dart';

import 'package:flutter/material.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  final firebaseQueries = Get.put(FirebaseQueries());

  //FUNCTIONS//

  getStudents() async {
    List<String> temptList = [];

    QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection("classGroups")
          .where("teacherID", isEqualTo: firebaseQueries.getCurrentUser()!.uid)
          .get();
    
    for (var classGroup in querySnapshot.docs) {
      for (var student in classGroup["students"]) {
        temptList.add(student);
      }
    }

    DocumentReference documentReference =
      FirebaseFirestore.instance.collection("admins")
          .doc(firebaseQueries.getCurrentUser()!.uid);

    DocumentSnapshot documentSnapshot = await documentReference.get();

    for (var student in temptList) {
      if (!documentSnapshot["students"].contains(student)) {
        documentReference
            .update({"students": FieldValue.arrayUnion([student])});
      }
    }
  }

  getClassGroups() async {
    Map<String, String> temptMap = {};

    QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection("admins")
          .doc(loginUser!.uid).collection("groups").get();
    
    for (var element in querySnapshot.docs) {
      temptMap[element.id] = element["groupName"];
    }

    classGroupsMap = temptMap;
  }

  //END OF FUNCTIONS//

  @override
  void initState() {
    super.initState();

    getStudents();
    getClassGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Row(
        children: [

          //left sidebar
          const LeftsideMenu(),

          Expanded( //to make column fit horizontal space
            child: Container( //to set background image
              //background image
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [

                  //titlebar
                  const Titlebar(),

                  //main space
                  Expanded(//to make image fit horizontal space
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Image.asset(
                          "assets/images/appletree_logo.png",
                          height: 150.0,
                          width: 150.0,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ]
      ),
    );
  }
}

class Titlebar extends StatelessWidget {
  const Titlebar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      color: Colors.primary_dark,
      child: const Row(
        children: [
          Expanded(//to make text fit horizontal space
              child: Center(
                  child: Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text(
                        "",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ))))
        ],
      ),
    );
  }
}
