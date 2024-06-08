import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  String? id;
  String? questionNumber;
  String? questionContent;
  List<String>? answersList;
  List<int>? numbersCorrectAnswers;

  //Constructor
  QuestionModel({this.questionNumber, this.questionContent,
    this.answersList, this.numbersCorrectAnswers});


  Map<String, dynamic> toJson() {
    return <String, dynamic> {
      "questionContent": questionContent,
      "answersList": answersList,
      "numbersCorrectAnswers": numbersCorrectAnswers,
    };
  }

  factory QuestionModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return QuestionModel(
      questionContent: data?["questionContent"],
      answersList: data?["answersList"],
      numbersCorrectAnswers: data?["numbersCorrectAnswers"],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (questionContent != null) "questionContent": questionContent,
      if (answersList != null) "answersList": answersList,
      if (numbersCorrectAnswers != null) "numbersCorrectAnswers": numbersCorrectAnswers,
    };
  }

}