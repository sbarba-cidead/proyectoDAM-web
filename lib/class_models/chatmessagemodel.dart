import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  String? message;
  String? senderId;
  Timestamp? timestamp;

  //Constructor
  ChatMessageModel({this.message, this.senderId, this.timestamp});


  Map<String, dynamic> toJson() {
    return <String, dynamic> {
      "message": message,
      "senderId": senderId,
      "timestamp": timestamp,
    };
  }

  factory ChatMessageModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return ChatMessageModel(
      message: data?["message"],
      senderId: data?["senderId"],
      timestamp: data?["timestamp"],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (message != null) "message": message,
      if (senderId != null) "userIds": senderId,
      if (timestamp != null) "timestamp": timestamp,
    };
  }

}