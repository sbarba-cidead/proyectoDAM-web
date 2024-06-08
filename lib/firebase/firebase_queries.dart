import '../class_models/chatroommodel.dart';
import '../class_models/questionmodel.dart';
import '/class_models/taskmodel.dart';
import '/class_models/quizmodel.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';


class FirebaseQueries extends GetxController {
  static FirebaseQueries get instance => Get.find();

  final _auth = FirebaseAuth.instance;
  final _database = FirebaseFirestore.instance;
  User? currentUser;

  User? getCurrentUser(){
    return _auth.currentUser;
  }

  Future<String> getUsername() async {
    var username = "";

    await _database.collection("admins")
        .doc(getCurrentUser()!.uid).get().then((snap) {
          username = snap.get("name").toString();
        });

    return username;
  }

  //FUNCTIONS//

  /////QUIZZES/////

  Future<String> addQuiz(QuizModel quiz) async {
    final document = await FirebaseFirestore.instance
        .collection("quizes")
        .doc(getCurrentUser()!.uid)
        .collection("quizes")
        .add(quiz.toJson())
        .whenComplete((){
          Get.snackbar("", "",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.primary_dark_transparent,
            titleText: const SizedBox(),
            messageText: const Center(
                child: Text(
                  "Nuevo test creado correctamente.",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                )),
            margin: const EdgeInsets.all(30),
            isDismissible: false,
          );
        })
        .catchError((error, stackTrace){
          Get.snackbar("", "",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.primary_dark_transparent,
            titleText: const SizedBox(),
            messageText: const Center(
              child: Text(
                      "No se pudo añadir el test.\nInténtalo de nuevo.",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    )
              ),
            margin: const EdgeInsets.all(30),
            isDismissible: false,
          );
          return error;
        });

    //saves teacher's email as field
    await FirebaseFirestore.instance
        .collection("quizes")
        .doc(getCurrentUser()!.uid)
        .set({"user": getCurrentUser()!.email});

    //saves quiz id as field
    await FirebaseFirestore.instance
        .collection("quizes")
        .doc(getCurrentUser()!.uid)
        .collection("quizes")
        .doc(document.id)
        .update({"quizID": document.id});

    return document.id;
  }

  void addQuestion(String quizID, QuestionModel question) async {
    await FirebaseFirestore.instance
        .collection("quizes")
        .doc(getCurrentUser()!.uid)
        .collection("quizes")
        .doc(quizID)
        .collection("questions")
        .doc(question.questionNumber)
        .set(question.toJson())
        .catchError((error, stackTrace){
          Get.snackbar("", "",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.primary_dark_transparent,
            titleText: const SizedBox(),
            messageText: const Center(
                child: Text(
                  "No se pudo añadir la pregunta.\nInténtalo de nuevo.",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                )),
            margin: const EdgeInsets.all(30),
            isDismissible: false,
          );
          return error;
        });
  }

  void removeQuiz(String quizID) async {
    await _database.collection("quizes")
        .doc(getCurrentUser()!.uid)
        .collection("quizes")
        .doc(quizID)
        .collection("questions").get().then((snapshot) {
          for (DocumentSnapshot doc in snapshot.docs) {
            doc.reference.delete();
          }
        })
        .then((a) {
          _database.collection("quizes")
              .doc(getCurrentUser()!.uid)
              .collection("quizes")
              .doc(quizID)
              .delete()
              .then((a) {
                Get.snackbar("", "",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.primary_dark_transparent,
                  titleText: const SizedBox(),
                  messageText: const Center(
                      child: Text(
                        "Test eliminado correctamente.",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      )),
                  margin: const EdgeInsets.all(30),
                  isDismissible: false,
                );
              })
              .catchError((error, stackTrace){
                Get.snackbar("", "",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.primary_dark_transparent,
                  titleText: const SizedBox(),
                  messageText: const Center(
                      child: Text(
                        "No se pudo eliminar el test.\nInténtalo de nuevo más tarde.",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      )),
                  margin: const EdgeInsets.all(30),
                  isDismissible: false,
                );
                return error;
              });
        })
        .catchError((error, stackTrace){
          Get.snackbar("", "",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.primary_dark_transparent,
            titleText: const SizedBox(),
            messageText: const Center(
                child: Text(
                  "No se pudo eliminar el test.\nInténtalo de nuevo más tarde.",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                )),
            margin: const EdgeInsets.all(30),
            isDismissible: false,
          );
          return error;
        });
  }

  /////LOGIN/////

  /// tries to login with the username and password given
  Future<bool> tryLogin(String username, String password) async {
    var response = false;

    await _auth.signInWithEmailAndPassword(
        email: username, password: password)
        .then((firebaseAuth) {
          currentUser = firebaseAuth.user;
        }
      )
      .then((a) async {
        var userIsAdmin = checkIfAdmin(currentUser);
        if (await userIsAdmin){ response = true; }
      })

      .catchError((onError) {
        Get.snackbar("", "",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.primary_dark_transparent,
          titleText: const SizedBox(),
          messageText: const Center(
            child: Text(
              "Los datos de inicio de sesión no son correctos.\nInténtalo de nuevo.",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            )
          ),
          margin: const EdgeInsets.all(30),
          isDismissible: false,
        );
      });

    return response;
  }

  /// checks if the user given is admin
  Future<bool> checkIfAdmin(User? currentUser) async {
    var response = false;

    if(currentUser != null){
      //Checks if credentials are for a teacher
      await _database.collection("admins")
          .doc(currentUser.uid).get().then((snap){
            if(snap.exists){ //if the username is admin
              Get.snackbar("", "",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.primary_dark_transparent,
                titleText: const SizedBox(),
                messageText: const Center(
                    child: Text(
                      "Inicio de sesión correcto.",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    )),
                margin: const EdgeInsets.all(30),
                isDismissible: false,
              );
              response = true;
            } else { //if the username is not admin
              Get.snackbar("", "",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.primary_dark_transparent,
                titleText: const SizedBox(),
                messageText: const Center(
                    child: Text(
                      "Acceso no permitido para este usuario.\nInténtalo de nuevo.",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    )),
                margin: const EdgeInsets.all(30),
                isDismissible: false,
              );
            }
          }
      );
    }

    return response;
  }

  /////LOGOUT/////

  void logout() {
    Get.snackbar("", "",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.primary_dark_transparent,
      titleText: const SizedBox(),
      messageText: const Center(
          child: Text(
            "Cierre de sesión correcto.",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          )),
      margin: const EdgeInsets.all(30),
      isDismissible: false,
    );

    FirebaseAuth.instance.signOut();
  }

  /////TASKS/////

  /// creates new task adding it to firebase
  void createTask(String contentTask, Timestamp dueDateTask, String group, String groupName) async {
    String formattedDueDate = DateFormat("dd/MM/yyyy HH:mm").format(dueDateTask.toDate());

    TaskModel task = TaskModel(createdDate: Timestamp.fromDate(DateTime.now()),
        content: contentTask, dueDate: dueDateTask, formattedDueDate: formattedDueDate,
        group: group, groupName: groupName, completedStudents: []);

    final document = await _database
                  .collection("tasks")
                  .doc(getCurrentUser()!.uid)
                  .collection("tasks")
                  .withConverter(
                    fromFirestore: TaskModel.fromFirestore,
                    toFirestore: (TaskModel task, options) => task.toFirestore(),
                  ).add(task)
                  .catchError((error, stackTrace){
                    Get.snackbar("", "",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.primary_dark_transparent,
                      titleText: const SizedBox(),
                      messageText: const Center(
                        child: Text(
                          "No se pudo crear la tarea.\nInténtalo de nuevo más tarde.",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                      margin: const EdgeInsets.all(30),
                      isDismissible: false,
                    );
                    return error;
                  });

    await FirebaseFirestore.instance
        .collection("tasks")
        .doc(getCurrentUser()!.uid)
        .collection("tasks")
        .doc(document.id)
        .update({"taskID": document.id})
        .then((a) {
          Get.snackbar("", "",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.primary_dark_transparent,
            titleText: const SizedBox(),
            messageText: const Center(
                child: Text(
                  "Nueva tarea creada correctamente.",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                )),
            margin: const EdgeInsets.all(30),
            isDismissible: false,
          );
        })
        .catchError((error, stackTrace){
          Get.snackbar("", "",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.primary_dark_transparent,
            titleText: const SizedBox(),
            messageText: const Center(
                child: Text(
                  "No se pudo crear la tarea.\nInténtalo de nuevo más tarde.",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                )),
            margin: const EdgeInsets.all(30),
            isDismissible: false,
          );
          return error;
        });
  }

  /// updates task from firebase
  void editTask(String taskID, String contentTask, Timestamp dueDateTask, String group, String groupName) async {
    String formattedDueDate = DateFormat("dd/MM/yyyy HH:mm").format(dueDateTask.toDate());

    await FirebaseFirestore.instance.collection("tasks")
        .doc(getCurrentUser()!.uid).collection("tasks").doc(taskID)
        .update({'content': contentTask, 'dueDate': dueDateTask,
                'formattedDueDate': formattedDueDate, 'group': group, 'groupName': groupName})
        .then((a) {
          Get.snackbar("", "",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.primary_dark_transparent,
            titleText: const SizedBox(),
            messageText: const Center(
                child: Text(
                  "Tarea editada correctamente.",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                )),
            margin: const EdgeInsets.all(30),
            isDismissible: false,
          );
        })
        .catchError((error, stackTrace){
          Get.snackbar("", "",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.primary_dark_transparent,
            titleText: const SizedBox(),
            messageText: const Center(
                child: Text(
                  "No se pudo editar la tarea.\nInténtalo de nuevo más tarde.",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                )),
            margin: const EdgeInsets.all(30),
            isDismissible: false,
          );
          return error;
        });
  }

  /// removes given task from firebase
  void removeTask(String taskID) async {
    await _database.collection("tasks")
        .doc(getCurrentUser()!.uid)
        .collection("tasks")
        .doc(taskID).delete()
        .then((a) {
          Get.snackbar("", "",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.primary_dark_transparent,
            titleText: const SizedBox(),
            messageText: const Center(
                child: Text(
                  "Tarea eliminada correctamente.",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                )),
            margin: const EdgeInsets.all(30),
            isDismissible: false,
          );
        })
        .catchError((error, stackTrace){
          Get.snackbar("", "",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.primary_dark_transparent,
            titleText: const SizedBox(),
            messageText: const Center(
              child: Text(
                "No se pudo eliminar la tarea.\nInténtalo de nuevo más tarde.",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              )),
            margin: const EdgeInsets.all(30),
            isDismissible: false,
          );
          return error;
        });
  }

  /////CHAT/////

  void addChatroom(String chatroomId, ChatroomModel chatroom) async {
    await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatroomId)
        .set(chatroom.toJson())
        .catchError((error, stackTrace){
          Get.snackbar("", "",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.primary_dark_transparent,
            titleText: const SizedBox(),
            messageText: const Center(
                child: Text(
                  "No se pudo crear un chatroom.\nInténtelo de nuevo.",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                )),
            margin: const EdgeInsets.all(30),
            isDismissible: false,
          );
          return error;
        });
  }

  void updateChatroom(String chatroomId, Timestamp lastMessageTimestamp,
      String lastMessageSenderId) async {
    await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatroomId)
        .update({
          "lastMessageTimestamp": lastMessageTimestamp,
          "lastMessageSenderId": lastMessageSenderId,
        });
  }


}
