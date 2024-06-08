import 'package:cloud_firestore/cloud_firestore.dart';

class ChatroomModel {
  String? chatroomId;
  List<String>? userIds;
  Timestamp? lastMessageTimestamp;
  String? lastMessageSenderId;

  //Constructor
  ChatroomModel({this.chatroomId, this.userIds,
    this.lastMessageTimestamp, this.lastMessageSenderId});


  Map<String, dynamic> toJson() {
    return <String, dynamic> {
      "chatroomId": chatroomId,
      "userIds": userIds,
      "lastMessageTimestamp": lastMessageTimestamp,
      "lastMessageSenderId": lastMessageSenderId
    };
  }

  factory ChatroomModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return ChatroomModel(
      chatroomId: data?["chatroomId"],
      userIds: data?["userIds"],
      lastMessageTimestamp: data?["lastMessageTimestamp"],
      lastMessageSenderId: data?["lastMessageSenderId"],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (chatroomId != null) "chatroomId": chatroomId,
      if (userIds != null) "userIds": userIds,
      if (lastMessageTimestamp != null) "lastMessageTimestamp": lastMessageTimestamp,
      if (lastMessageSenderId != null) "lastMessageSenderId": lastMessageSenderId,
    };
  }

}