import 'package:appletreeweb/utilities/variables.dart';

import '../../widgets/CompleteTaskStreamBuilder.dart';
import '../../widgets/IncompleteTaskStreamBuilder.dart';
import '../../widgets/QuizUpdatableStreamBuilder.dart';
import '/widgets/leftsidemenu.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class StudentFollowupPage extends StatefulWidget {
  const StudentFollowupPage({super.key});

  @override
  State<StudentFollowupPage> createState() => _StudentFollowupPageState();
}

class _StudentFollowupPageState extends State<StudentFollowupPage> {

  late FirebaseFirestore database;
  late FirebaseAuth auth;
  late User? loginUser;

  String username = "";

  @override
  void initState() {
    super.initState();

    auth = FirebaseAuth.instance;
    loginUser = auth.currentUser;
    database = FirebaseFirestore.instance;

    username = loginUser!.email!;
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
                            Expanded(//to make column fit horizontal space
                                child: Padding(//to create some margin around
                                    padding: const EdgeInsets.all(40.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            //completed tasks total number
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const Padding(
                                                        padding: EdgeInsets.only(right: 10),
                                                        child: Text(
                                                            "Número de tareas completadas:",
                                                            style: TextStyle(
                                                              fontSize: 18, color: Colors.black,
                                                            )
                                                        ),
                                                      ),
                                                      StreamBuilder<QuerySnapshot>(
                                                        stream: FirebaseFirestore.instance.collection("users")
                                                            .doc(studentID)
                                                            .collection("tasks")
                                                            .where("done", isEqualTo: true).snapshots(),
                                                        builder: (context, snapshot) {
                                                          if (snapshot.hasData) {
                                                            return Text(
                                                                snapshot.data!.size.toString(),
                                                                style: const TextStyle(
                                                                  fontSize: 18, color: Colors.black,
                                                                )
                                                            );
                                                          } else {
                                                            return const Text("0");
                                                          }
                                                        }
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            
                                            //completed tests total number
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const Padding(
                                                        padding: EdgeInsets.only(right: 10),
                                                        child: Text(
                                                            "Número de cuestionarios completados:",
                                                            style: TextStyle(
                                                              fontSize: 18, color: Colors.black,
                                                            )
                                                        ),
                                                      ),
                                                      StreamBuilder<QuerySnapshot>(
                                                        stream: FirebaseFirestore.instance.collection("users")
                                                            .doc(studentID)
                                                            .collection("scoreQuizes")
                                                            .where("completed", isEqualTo: true).snapshots(),
                                                        builder: (context, snapshot) {
                                                          if (snapshot.hasData) {
                                                            return Text(
                                                                snapshot.data!.size.toString(),
                                                                style: const TextStyle(
                                                                  fontSize: 18, color: Colors.black,
                                                                )
                                                            );
                                                          } else {
                                                            return const Text("0");
                                                          }
                                                        }
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(
                                          height: 40,
                                        ),

                                        
                                        const Expanded(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              //tasks
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    //completed tasks
                                                    Text(
                                                        "Tareas completadas:",
                                                        style: TextStyle(
                                                          fontSize: 18, color: Colors.black,
                                                        )
                                                    ),
                                                    Expanded(
                                                        child: CompleteTaskStreamBuilder()
                                                    ),

                                                    SizedBox(
                                                      height: 20,
                                                    ),

                                                    //not completed tasks
                                                    Text(
                                                        "Tareas pendientes:",
                                                        style: TextStyle(
                                                          fontSize: 18, color: Colors.black,
                                                        )
                                                    ),
                                                    Expanded(
                                                        child: IncompleteTaskStreamBuilder()
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              //list of completed tests
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Text(
                                                        "Cuestionarios realizados:",
                                                        style: TextStyle(
                                                          fontSize: 18, color: Colors.black,
                                                        )
                                                    ),
                                                    Expanded(
                                                        child: QuizUpdatableStreamBuilder(),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                )
                            )
                          ]
                      )
                  )
              )
            ]
        )
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
      child: Row(
        children: [
          Expanded(//to make text fit horizontal space
              child: Center(
                  child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text(
                        "Seguimiento de $studentName",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ))))
        ],
      ),
    );
  }
}
