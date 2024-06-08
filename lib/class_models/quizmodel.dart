import 'package:cloud_firestore/cloud_firestore.dart';

class QuizModel {
  String? quizID;
  Timestamp? createdDate;
  String? quizName;
  String? level;
  String? subject;
  String? group;
  bool? hidden;
  List? completedStudents;

  //Constructor
  QuizModel({this.quizID, this.createdDate, this.quizName,
    this.level, this.subject, this.group, this.hidden,
    this.completedStudents});

  String? get id => quizID;

  set id(String? id) {
      quizID = id;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic> {
      "createdDate": createdDate,
      "quizName": quizName,
      "level": level,
      "subject": subject,
      "group": group,
      "hidden": hidden,
      "completedStudents": completedStudents,
    };
  }

  factory QuizModel.fromJson(Map<String, dynamic> json) => QuizModel(
      createdDate: json["createdDate"] as Timestamp,
      quizName: json["quizName"] as String,
      level: json["level"] as String,
      subject: json["subject"] as String,
      group: json["group"] as String,
      hidden: json["hidden"] as bool,
      completedStudents: json["completedStudents"] as List,
  );

  factory QuizModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return QuizModel(
      createdDate: data?["createdDate"],
      quizName: data?["quizName"],
      level: data?["level"],
      subject: data?["subject"],
      group: data?["group"],
      hidden: data?["hidden"],
      completedStudents: data?["completedStudents"]
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (createdDate != null) "createdDate": createdDate,
      if (quizName != null) "quizName": quizName,
      if (level != null) "level": level,
      if (subject != null) "subject": subject,
      if (group != null) "group": group,
      if (hidden != null) "hidden": hidden,
      if (completedStudents != null) "completedStudents": completedStudents,
    };
  }
}