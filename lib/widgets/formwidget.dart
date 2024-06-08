import 'package:appletreeweb/widgets/customcheckbox.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../class_models/questionmodel.dart';
import '../class_models/quizmodel.dart';
import '../firebase/firebase_queries.dart';
import '../utilities/app_routes.dart';
import '../utilities/variables.dart';


class FormWidget extends StatefulWidget {
  const FormWidget({Key? key}) : super(key: key);

  @override
  State<FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  //VARIABLES//
  final _formKey = GlobalKey<FormState>();

  TextEditingController questionController = TextEditingController();
  TextEditingController answer1Controller = TextEditingController();
  TextEditingController answer2Controller = TextEditingController();
  TextEditingController answer3Controller = TextEditingController();
  TextEditingController answer4Controller = TextEditingController();
  TextEditingController quizNameController = TextEditingController();

  bool checkbox1 = false;
  bool checkbox2 = false;
  bool checkbox3 = false;
  bool checkbox4 = false;

  int questionNumber = 1;
  String questionNumberText = "Pregunta 1";
  List<int> numbersCorrectAnswers = [];
  List<QuestionModel> tempSavedQuestions = [];

  //selected item for dropdown menus
  String levelSelected = "";
  String subjectSelected = "";
  String classGroupsSelected = "";

  //lists of items for dropdown menus
  final levelsDropdown = List.generate(
                                levels.length,
                                (index) => DropdownMenuItem(
                                  value: levels.keys.elementAt(index).toString(),
                                  child: Text(
                                    levels.values.elementAt(index).toString(),
                                  ),
                                ),
                              );
  final subjectsDropdown = List.generate(
                                subjects.length,
                                (index) => DropdownMenuItem(
                                  value: subjects.keys.elementAt(index).toString(),
                                  child: Text(
                                    subjects.values.elementAt(index).toString(),
                                  ),
                                ),
                              );
  final classGroupsDropdown = List.generate(
                              classGroupsMap.length,
                              (index) => DropdownMenuItem(
                                value: classGroupsMap.keys.elementAt(index),
                                child: Text(
                                  classGroupsMap.values.elementAt(index),
                                ),
                              ),
                            );  
  
  //END OF VARIABLES//

  @override
  void initState() {
    super.initState();

    levelSelected = levelsDropdown.elementAt(0).value.toString();
    subjectSelected = subjectsDropdown.elementAt(0).value.toString();
    classGroupsSelected = classGroupsDropdown.elementAt(0).value.toString();
  }

  @override
  Widget build(BuildContext context) {

    //FUNCTIONS//

    bool validateFields() {
      if(questionNumber == 1) {
        if(
            questionController.text.isNotEmpty &&
            answer1Controller.text.isNotEmpty &&
            answer2Controller.text.isNotEmpty &&
            answer3Controller.text.isNotEmpty &&
            answer4Controller.text.isNotEmpty &&
                numbersCorrectAnswers.isNotEmpty
        ) {
          return true;
        } else {
          // shows error message
          Get.snackbar("", "",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.primary_dark_transparent,
            titleText: const SizedBox(),
            messageText: const Center(
                child: Text(
                  "Error: Debe rellenar todos los campos.",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                )),
            margin: const EdgeInsets.all(30),
            isDismissible: false,
          );

          return false;
        }
      } else {
        return true;
      }
    }

    void addCorrectAnswer(int answerID) {
      numbersCorrectAnswers.add(answerID);
    }

    void removeCorrectAnswer(int answerID) {
      numbersCorrectAnswers.remove(answerID);
    }

    void saveQuestionLocally() {
      String questionContent = questionController.text;

      List<String> answersList = [];
      answersList.add(answer1Controller.text);
      answersList.add(answer2Controller.text);
      answersList.add(answer3Controller.text);
      answersList.add(answer4Controller.text);

      QuestionModel question = QuestionModel(
          questionNumber: "pregunta$questionNumber",
          questionContent: questionContent,
          answersList: answersList,
          numbersCorrectAnswers: numbersCorrectAnswers);

      tempSavedQuestions.add(question);

      questionNumber += 1;

      Get.snackbar("", "",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.primary_dark_transparent,
        titleText: const SizedBox(),
        messageText: const Center(
            child: Text(
              "Se han guardado los datos de la pregunta.",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            )),
        margin: const EdgeInsets.all(30),
        isDismissible: false,
      );
    }

    void updateQuestionNumberText() {
      setState((){
        questionNumberText = 'Pregunta ${questionNumber.toString()}';
      });
    }

    /// function for cancel button
    cancelQuiz() {
      // shows cancellation message
      Get.snackbar("", "",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.primary_dark_transparent,
        titleText: const SizedBox(),
        messageText: const Center(
            child: Text(
              "Creación de test cancelada.\n"
                  "Los datos introducidos no se han guardado.",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            )),
        margin: const EdgeInsets.all(30),
        isDismissible: false,
      );

      // goes back to quizes screen
      Get.offNamed(AppRoutes.getQuizesRoute());
    }

    /// function for save button
    Future<void> saveQuiz() async {
      if (
        questionController.text.isNotEmpty &&
        answer1Controller.text.isNotEmpty &&
        answer2Controller.text.isNotEmpty &&
        answer3Controller.text.isNotEmpty &&
        answer4Controller.text.isNotEmpty &&
        numbersCorrectAnswers.isNotEmpty
      ) {
        saveQuestionLocally();
      }

      var hidden = true;
      if (levelSelected == "normal") { hidden=false; }

      QuizModel quiz = QuizModel(
          createdDate: Timestamp.fromDate(DateTime.now()),
          quizName: quizNameController.text,
          level: levelSelected,
          subject: subjectSelected,
          group: classGroupsSelected,
          hidden: hidden,
          completedStudents: [],
      );

      final firebaseQueries = Get.put(FirebaseQueries());
      String quizID = await firebaseQueries.addQuiz(quiz);

      for (QuestionModel question in tempSavedQuestions) {
        firebaseQueries.addQuestion(quizID, question);
      }

      // goes back to quizes screen
      Get.offNamed(AppRoutes.getQuizesRoute());
    }

    void showQuizNameDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: const Text("Crear nuevo test"),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField( //textfield for quiz name
                        controller: quizNameController,
                        onChanged: (value) {
                          quizNameController.value = TextEditingValue(
                            text: value.capitalizeFirst.toString(),
                            selection: TextSelection.fromPosition(
                              TextPosition(offset: value.length),
                            ),
                          );
                        },
                        decoration: const InputDecoration(
                            hintText: "Nombre del test"
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Nivel del test'
                        ),
                        isExpanded: true,
                        value: levelSelected,
                        items: levelsDropdown,
                        onChanged: (String? selectedItem) {
                          setState(() {
                            levelSelected = selectedItem!;
                          });
                        },
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            labelText: 'Asignatura'
                        ),
                        isExpanded: true,
                        value: subjectSelected,
                        items: subjectsDropdown,
                        onChanged: (String? selectedItem) {
                          setState(() {
                            subjectSelected = selectedItem!;
                          });
                        },
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            labelText: 'Clase y grupo'
                        ),
                        isExpanded: true,
                        value: classGroupsSelected,
                        items: classGroupsDropdown,
                        onChanged: (String? selectedItem) {
                          setState(() {
                            classGroupsSelected = selectedItem!;
                          });
                        },
                      ),
                    ]
                  ),
                actions: <Widget>[
                  TextButton( //cancel button
                    child: const Text('Cancelar'),
                    onPressed: () {
                      //closes dialog
                      Navigator.pop(context);
                    },
                  ),
                  TextButton( //save button
                    child: const Text('Aceptar'),
                    onPressed: () {
                      if (quizNameController.text.isNotEmpty) {
                        saveQuiz();
                      } else {
                        // shows error message
                        Get.snackbar("", "",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.primary_dark_transparent,
                          titleText: const SizedBox(),
                          messageText: const Center(
                              child: Text(
                                "Error: Debe rellenar todos los campos.",
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              )),
                          margin: const EdgeInsets.all(30),
                          isDismissible: false,
                        );
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    }

    /// function for add question button
    addNewQuestion() {
        saveQuestionLocally();

        updateQuestionNumberText();

        questionController.clear;
        answer1Controller.clear;
        answer2Controller.clear;
        answer3Controller.clear;
        answer4Controller.clear;

        questionController.clear();
        answer1Controller.clear();
        answer2Controller.clear();
        answer3Controller.clear();
        answer4Controller.clear();

        checkbox1 = false;
        checkbox2 = false;
        checkbox3 = false;
        checkbox4 = false;

        numbersCorrectAnswers = [];
    }

    //END OF FUNCTIONS//

    return Form(
      key: _formKey,
      child: Column(
        children: [

          //form buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //cancel button
              ElevatedButton(
                onPressed: (){
                  cancelQuiz();
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
                  "Cancelar",
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 2,
                    fontSize: 16,
                  ),
                ),
              ),

              //save botton
              ElevatedButton(
                onPressed: (){
                  if (validateFields()) {
                    // shows dialog to enter quiz name
                    showQuizNameDialog();
                  }
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
                  "Guardar test",
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 2,
                    fontSize: 16,
                  ),
                ),
              ),

              //add new question button
              ElevatedButton(
                onPressed: (){
                  if (validateFields()) {
                    addNewQuestion();

                    setState(() {});
                  }
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
                  "Añadir pregunta",
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 2,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10,),

          //form with fields for the question
          SizedBox(
            height: null,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Column(
                children: [

                  //question number header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 30
                    ),
                    child: Text(
                        questionNumberText,
                        style: const TextStyle(
                          fontSize: 18, color: Colors.black,
                          decorationThickness: 4
                        )
                    ),
                  ),

                  //fields for the question and answers
                  Column(
                      children:[
                        //question content textfield
                        TextField(
                          controller: questionController,
                          maxLength: 60,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                          decoration: const InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 2,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.orange,
                                  width: 2,
                                )),
                            hintText: "Contenido pregunta",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),

                        //answer1
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 5, bottom: 5,
                            left: 20,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 20,
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: answer1Controller,
                                      maxLength: 25,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                      decoration: const InputDecoration(
                                        counterText: '',
                                        filled: true,
                                        fillColor: Colors.white,
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                              width: 2,
                                            )),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.orange,
                                              width: 2,
                                            )),
                                        hintText: "Primera respuesta",
                                        hintStyle: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    CustomCheckbox(
                                        id: 1,
                                        isChecked: checkbox1,
                                        onCheckChanged: (bool isChecked, int answerID) {
                                          if (isChecked) {
                                            addCorrectAnswer(answerID);
                                          } else {
                                            removeCorrectAnswer(answerID);
                                          }
                                        }
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),

                        //answer2
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 5, bottom: 5,
                            left: 20,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 20,
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: answer2Controller,
                                      maxLength: 25,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                      decoration: const InputDecoration(
                                        counterText: '',
                                        filled: true,
                                        fillColor: Colors.white,
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                              width: 2,
                                            )),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.orange,
                                              width: 2,
                                            )),
                                        hintText: "Segunda respuesta",
                                        hintStyle: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                  child: Column(
                                    children: [
                                      CustomCheckbox(
                                          id: 2,
                                          isChecked: checkbox2,
                                          onCheckChanged: (bool isChecked, int answerID) {
                                            if (isChecked) {
                                              addCorrectAnswer(answerID);
                                            } else {
                                              removeCorrectAnswer(answerID);
                                            }
                                          }
                                      ),
                                    ],
                                  )
                              )
                            ],
                          ),
                        ),

                        //answer3
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 5, bottom: 5,
                            left: 20,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 20,
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: answer3Controller,
                                      maxLength: 25,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                      decoration: const InputDecoration(
                                        counterText: '',
                                        filled: true,
                                        fillColor: Colors.white,
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                              width: 2,
                                            )),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.orange,
                                              width: 2,
                                            )),
                                        hintText: "Tercera respuesta",
                                        hintStyle: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                  child: Column(
                                    children: [
                                      CustomCheckbox(
                                          id: 3,
                                          isChecked: checkbox3,
                                          onCheckChanged: (bool isChecked, int answerID) {
                                            if (isChecked) {
                                              addCorrectAnswer(answerID);
                                            } else {
                                              removeCorrectAnswer(answerID);
                                            }
                                          }
                                      ),
                                    ],
                                  )
                              )
                            ],
                          ),
                        ),

                        //answer4
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 5, bottom: 5,
                            left: 20,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 20,
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: answer4Controller,
                                      maxLength: 25,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                      decoration: const InputDecoration(
                                        counterText: '',
                                        filled: true,
                                        fillColor: Colors.white,
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                              width: 2,
                                            )),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.orange,
                                              width: 2,
                                            )),
                                        hintText: "Cuarta respuesta",
                                        hintStyle: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                  child: Column(
                                    children: [
                                      CustomCheckbox(
                                          id: 4,
                                          isChecked: checkbox4,
                                          onCheckChanged: (bool isChecked, int answerID) {
                                            if (isChecked) {
                                              addCorrectAnswer(answerID);
                                            } else {
                                              removeCorrectAnswer(answerID);
                                            }
                                          }
                                      ),
                                    ],
                                  )
                              )
                            ],
                          ),
                        ),
                      ]),

                ]
              )
            ),
          ),
        ],
      )
    );
  }

}