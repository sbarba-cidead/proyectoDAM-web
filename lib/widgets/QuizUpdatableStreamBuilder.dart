import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utilities/variables.dart';


class QuizUpdatableStreamBuilder extends StatefulWidget {
  const QuizUpdatableStreamBuilder({Key? key}) : super(key: key);

  @override
  State<QuizUpdatableStreamBuilder> createState() => _QuizUpdatableStreamBuilderState();
}

class _QuizUpdatableStreamBuilderState extends State<QuizUpdatableStreamBuilder> {
  //VARIABLES//
  bool attemptSelected = false;
  bool quizSelected = false;
  Stream<QuerySnapshot>? quizStream;
  String quizSubtitleLabel = "";
  String quizSubtitleQuery = "";
  bool averageGradeVisible = true;

  String selectedQuizID = "";
  String selectedQuizName = "";
  String selectedAttemptNumber = "";

  String attemptDate = "";
  int attemptDuration = 0;
  String attemptQuestionNumber = "";
  String attemptRightAnswers = "";
  String attemptWrongAnswers = "";
  List<String> attemptWrongQuestions = <String>[];

  bool backButtonVisible = false;

  @override
  void initState() {
    super.initState();

    attemptSelected = false;
    quizSelected = false;
    quizStream = FirebaseFirestore.instance.collection("users")
        .doc(studentID)
        .collection("scoreQuizes")
        .orderBy("quizName", descending: false)
        .snapshots();
    quizSubtitleLabel = "Intentos";
    quizSubtitleQuery = "totalAttempts";
    averageGradeVisible = true;
  }

  @override
  Widget build(BuildContext context) {
    //FUNCTIONS//
    String convertSecondsToHourMinuteSecond(int seconds) {
      Duration duration = Duration(seconds: seconds);

      String twoDigits(int number) => number.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());

      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SingleChildScrollView(
              child: StreamBuilder<QuerySnapshot>(
                stream: quizStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text(
                        "Se ha producido un error.");
                  }

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator()
                    );
                  } else {
                    final list = snapshot.data!.docs;

                    return list.isNotEmpty
                        ? SizedBox(
                            width: 500,
                            height: 350,
                            child: RawScrollbar(
                              controller: PrimaryScrollController.of(context),
                              thumbVisibility: true,
                              thumbColor: Colors.primary_dark_transparent,
                              radius: const Radius.circular(20),
                              thickness: 8,
                              child:
                                attemptSelected == false
                                  ? ListView.builder(
                                    controller: ScrollController(),
                                    itemCount: list.length,
                                    itemBuilder: (context, position) {
                                      return Material(
                                        color: Colors.transparent,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 8),
                                          child: ListTile(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            tileColor: quizSelected == true
                                              ? Colors.primary_light
                                              : list[position]["completed"]
                                                ? Colors.complete_green
                                                : Colors.primary_light,
                                            title: Text(
                                              quizSelected == false
                                                  ? '${list[position]["quizName"]}'
                                                  : '${list[position]["quizName"]} Intento ${position+1}',
                                              style: const TextStyle(
                                                  color: Colors.white
                                              ),
                                            ),
                                            subtitle: Padding(
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '$quizSubtitleLabel: ${list[position][quizSubtitleQuery]}',
                                                    style: const TextStyle(
                                                        color: Colors.white
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: averageGradeVisible,
                                                    child: Text(
                                                      averageGradeVisible
                                                      ? 'Nota media: ${list[position]["averageGrade"]}'
                                                      : '',
                                                      style: const TextStyle(
                                                          color: Colors.white
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                if (!quizSelected) {
                                                  selectedQuizID = list[position]["quizID"];
                                                  selectedQuizName = list[position]["quizName"];

                                                  quizStream = FirebaseFirestore.instance.collection("users")
                                                      .doc(studentID)
                                                      .collection("quizesAttempts")
                                                      .where("quizID", isEqualTo: selectedQuizID)
                                                      .snapshots();

                                                  quizSubtitleLabel = "Fecha";
                                                  quizSubtitleQuery = "formattedDate";
                                                  averageGradeVisible = false;
                                                  quizSelected = true;
                                                  backButtonVisible = true;
                                                } else {
                                                  attemptSelected = true;
                                                  selectedAttemptNumber = (position+1).toString();

                                                  attemptDate = list[position]["formattedDate"].toString();
                                                  attemptDuration = list[position]["completeTimeSecs"];
                                                  attemptQuestionNumber = list[position]["totalQuestionsNumber"].toString();
                                                  attemptRightAnswers = list[position]["correctAnswers"].toString();
                                                  attemptWrongAnswers = list[position]["incorrectAnswers"].toString();
                                                  attemptWrongQuestions =
                                                      List.from(list[position]["incorrectAnswersList"]);
                                                  backButtonVisible = true;
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      );
                                    }
                                  )
                                  : SizedBox(
                                    width: MediaQuery.of(context).size.width - 250,
                                    height: 10,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.primary_light,
                                          ),
                                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                                          color: Colors.primary_light,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(30),
                                          child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "$selectedQuizName Intento $selectedAttemptNumber",
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(
                                                  height: 20,
                                                ),

                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    const Text(
                                                      "Fecha:",
                                                      style: TextStyle(
                                                          color: Colors.white
                                                      ),
                                                    ),
                                                    Text(
                                                      attemptDate,
                                                      style: const TextStyle(
                                                          color: Colors.white
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    const Text(
                                                      "Duración:",
                                                      style: TextStyle(
                                                          color: Colors.white
                                                      ),
                                                    ),
                                                    Text(
                                                      convertSecondsToHourMinuteSecond(attemptDuration),
                                                      style: const TextStyle(
                                                          color: Colors.white
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    const Text(
                                                      "Preguntas:",
                                                      style: TextStyle(
                                                          color: Colors.white
                                                      ),
                                                    ),
                                                    Text(
                                                      attemptQuestionNumber,
                                                      style: const TextStyle(
                                                          color: Colors.white
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    const Text(
                                                      "Aciertos:",
                                                      style: TextStyle(
                                                          color: Colors.white
                                                      ),
                                                    ),
                                                    Text(
                                                      attemptRightAnswers,
                                                      style: const TextStyle(
                                                          color: Colors.white
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    const Text(
                                                      "Fallos:",
                                                      style: TextStyle(
                                                          color: Colors.white
                                                      ),
                                                    ),
                                                    Text(
                                                      attemptWrongAnswers,
                                                      style: const TextStyle(
                                                          color: Colors.white
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Preguntas falladas:",
                                                      style: TextStyle(
                                                          color: Colors.white
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 100,
                                                      child: attemptWrongQuestions.isNotEmpty
                                                        ? ListView.builder(
                                                            itemCount: attemptWrongQuestions.length,
                                                            itemBuilder: (BuildContext context, int index) {
                                                              return Padding(
                                                                padding: const EdgeInsets.only(left: 10.0),
                                                                child: Text(
                                                                  attemptWrongQuestions[index],
                                                                  style: const TextStyle(
                                                                      color: Colors.white
                                                                  ),
                                                                ),
                                                              );
                                                          })
                                                      : const Expanded(child:
                                                          Center(child:
                                                            Text(
                                                              "No se han fallado preguntas.",
                                                              style: TextStyle(
                                                                  color: Colors.white
                                                              ),
                                                            )
                                                          )
                                                        ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                            ),
                    )
                        : const Center(child:
                          Text("No se han completado cuestionarios.")
                        );
                  }
                },
              ),
            ),
          ),
        ),
        Visibility(
          visible: backButtonVisible,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                if (quizSelected) {
                  quizStream = FirebaseFirestore.instance.collection("users")
                      .doc(studentID)
                      .collection("scoreQuizes")
                      .orderBy("quizName", descending: false)
                      .snapshots();
                  quizSubtitleLabel = "Intentos";
                  quizSubtitleQuery = "totalAttempts";
                  averageGradeVisible = true;
                  quizSelected = false;
                  backButtonVisible = false;

                  if (attemptSelected) {
                    quizStream = FirebaseFirestore.instance.collection("users")
                        .doc(studentID)
                        .collection("quizesAttempts")
                        .where("quizID", isEqualTo: selectedQuizID)
                        .snapshots();
                    quizSubtitleLabel = "Fecha";
                    quizSubtitleQuery = "formattedDate";
                    averageGradeVisible = false;
                    attemptSelected = false;
                    quizSelected = true;
                    backButtonVisible = true;
                  }
                }
              });
            },
            onHover: (value) {},
            style: ButtonStyle(
              padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 20,
                  )),
              foregroundColor: MaterialStateProperty.all(
                Colors.primary_dark,
              ),
              backgroundColor: MaterialStateProperty.all(
                Colors.primary_dark,
              ),
              //hover and pressed effects
              overlayColor:
              MaterialStateProperty.resolveWith(
                    (Set<MaterialState> states) {
                  if (states
                      .contains(MaterialState.hovered)) {
                    return Colors
                        .blueGrey; //if button is hovered
                  } else if (states
                      .contains(MaterialState.pressed)) {
                    return Colors
                        .primary_light; //if button is pressed
                  } else {
                    return null; // default color
                  }
                },
              ),
            ),
            child: const Text(
              "Atrás",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 2,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}