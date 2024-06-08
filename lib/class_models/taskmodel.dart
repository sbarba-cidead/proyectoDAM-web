import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  Timestamp? createdDate;
  String? content;
  Timestamp? dueDate;
  String? formattedDueDate;
  String? taskID;
  String? group;
  String? groupName;
  List? completedStudents;

  //Constructor
  TaskModel({this.createdDate, this.content, this.dueDate,
    this.formattedDueDate, this.taskID, this.group, this.groupName,
    this.completedStudents});

  factory TaskModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return TaskModel(
      createdDate: data?["createdDate"],
      content: data?["content"],
      dueDate: data?["dueDate"],
      formattedDueDate: data?["formattedDueDate"],
      taskID: data?["taskID"],
      group: data?["group"],
      groupName: data?["groupName"],
      completedStudents: data?["completedStudents"]
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (createdDate != null) "createdDate": createdDate,
      if (content != null) "content": content,
      if (dueDate != null) "dueDate": dueDate,
      if (formattedDueDate != null) "formattedDueDate": formattedDueDate,
      if (taskID != null) "taskID": taskID,
      if (group != null) "group": group,
      if (groupName != null) "groupName": groupName,
      if (completedStudents != null) "completedStudents": completedStudents,
    };
  }

}