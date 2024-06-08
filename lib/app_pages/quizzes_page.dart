import '/firebase/firebase_queries.dart';
import '/utilities/variables.dart';
import '/utilities/app_routes.dart';
import '/widgets/leftsidemenu.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';
import 'package:flutter/material.dart';


class QuizesPage extends StatefulWidget {
  const QuizesPage({super.key});

  @override
  State<QuizesPage> createState() => _QuizesPageState();
}

class _QuizesPageState extends State<QuizesPage> {
  
  final firebaseQueries = Get.put(FirebaseQueries());

  goToNewQuiz() {
    Get.toNamed(AppRoutes.getCreateEditQuizRoute());
  }

  showConfirmDialog(String quizID) {
    //asks for old password
    showDialog(
        context: context,
        builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Confirmar borrado"),
                content: const Text("¿Seguro que quieres borrar el cuestionario? No se podrá recuperar."),
                actions: <Widget>[
                  TextButton( //cancel button
                    child: const Text('Cancelar'),
                    onPressed: () {
                      Get.snackbar("", "",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.primary_dark_transparent,
                        titleText: const SizedBox(),
                        messageText: const Center(
                            child: Text(
                              "Borrado de cuestionario cancelado.",
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            )),
                        margin: const EdgeInsets.all(30),
                        isDismissible: false,
                      );

                      //closes dialog
                      Navigator.pop(context);
                    },
                  ),
                  TextButton( //save button
                    child: const Text('Borrar'),
                    onPressed: () async {
                      //deletes quiz
                      firebaseQueries.removeQuiz(quizID);

                      //closes dialog
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
        },
      );
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

                  //main space for quizes
                  Expanded(//to make column fit horizontal space
                    child: Padding(//to create some margin around
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Center(//to make button fit horizontal space
                            child: ElevatedButton(
                                onPressed: (){
                                  goToNewQuiz();
                                },
                                onHover: (value){},
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                      horizontal: 50,
                                      vertical: 20,
                                    )
                                  ),
                                  foregroundColor: MaterialStateProperty.all(
                                    Colors.primary_dark,
                                  ),
                                  backgroundColor: MaterialStateProperty.all(
                                    Colors.primary_dark,
                                  ),
                                //hover and pressed effects
                                overlayColor: MaterialStateProperty.resolveWith(
                                  (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.hovered)) {
                                      return Colors.blueGrey; //if button is hovered
                                    } else if (states.contains(MaterialState.pressed)) {
                                      return Colors.primary_light; //if button is pressed
                                    } else {
                                      return null; // default color
                                    }
                                  },
                                ),
                              ),
                              child: const Text(
                                "Crear nuevo test",
                                style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40,),

                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                StreamBuilder<QuerySnapshot>(
                                  stream:
                                  FirebaseFirestore.instance.collection("quizes")
                                      .doc(loginUser!.uid)
                                      .collection("quizes").snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasError) {
                                      return const Text(
                                          "Se ha producido un error.");
                                    }

                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else {
                                      final list = snapshot.data!.docs;

                                      return list.isNotEmpty
                                          ? SizedBox(
                                              width: MediaQuery.of(context).size.width-200,
                                              height: MediaQuery.of(context).size.height-65,
                                              child: RawScrollbar(
                                                controller: PrimaryScrollController.of(context),
                                                thumbVisibility: true,
                                                thumbColor: Colors.primary_dark_transparent,
                                                radius: const Radius.circular(20),
                                                thickness: 8,
                                                child: GridView.builder(
                                                  controller: PrimaryScrollController.of(context),
                                                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                                      maxCrossAxisExtent: 200, //max width for tile
                                                      childAspectRatio: 3 / 2,
                                                      crossAxisSpacing: 20,
                                                      mainAxisSpacing: 20),
                                                  itemCount: list.length,
                                                  itemBuilder: (context, position) {
                                                    return Material(
                                                      color: Colors.transparent,
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 20, vertical: 8),
                                                        child: GridTile(
                                                          footer: TextButton(
                                                            onPressed: () {
                                                              showConfirmDialog(list[position].id);
                                                            },
                                                            child: const Icon(
                                                              Icons.delete_forever,
                                                              color: Colors.white,
                                                              size: 20,
                                                            ),
                                                          ),
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(20),
                                                              color: Colors.primary_light,
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(10),
                                                              child: Text(
                                                                list[position]["quizName"],
                                                                style: const TextStyle(
                                                                    color: Colors. white,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                ),
                                              ),
                                          )
                                          : const Expanded(child:
                                              Center(child:
                                                Text("No hay tests creados.")
                                              )
                                          );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )

                ],
              ),
            ),
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
      child: const Row(
        children: [
          Expanded(//to make text fit horizontal space
              child: Center(
                  child: Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text(
                        "Tests",
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
