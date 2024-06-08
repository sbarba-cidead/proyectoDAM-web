import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '/class_models/chatmessagemodel.dart';
import '/utilities/variables.dart';
import '/class_models/chatroommodel.dart';
import '/firebase/firebase_queries.dart';
import '/widgets/leftsidemenu.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';


class ChatroomPage extends StatefulWidget {
  const ChatroomPage({super.key});

  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {

  TextEditingController messageTextController = TextEditingController();

  late String chatroomId;
  late Stream<QuerySnapshot<Map<String, dynamic>>> messagesQuery;

  @override
  void initState() {
    super.initState();

    chatroomId = getChatroomId(loginUser!.uid, studentID);

    getOrCreateChatroomModel(chatroomId, studentID);

    messagesQuery = FirebaseFirestore.instance.collection("chatrooms")
        .doc(chatroomId)
        .collection("chats")
        .orderBy("timestamp", descending: true).snapshots();
  }

  void sendMessage(String messageText) {
    // updates the info for the last message sent in firebase
    final firebaseQueries = Get.put(FirebaseQueries());
    firebaseQueries.updateChatroom(chatroomId, Timestamp.now(), loginUser!.uid);

    // saves message to firebase
    final chatMessageModel = ChatMessageModel(
        message: messageText,
        senderId: loginUser!.uid,
        timestamp: Timestamp.now());
    FirebaseFirestore.instance.collection("chatrooms")
        .doc(chatroomId).collection("chats")
        .doc().set(chatMessageModel.toJson())
        .whenComplete(() => messageTextController.clear())
        .catchError((error, stackTrace){
          Get.snackbar("", "",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.primary_dark_transparent,
            titleText: const SizedBox(),
            messageText: const Center(
                child: Text(
                  "No se pudo enviar el mensaje.\nInténtelo de nuevo.",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                )),
            margin: const EdgeInsets.all(30),
            isDismissible: false,
          );
          return error;
        });
  }

  void getOrCreateChatroomModel(String chatroomId, String studentID) async {
    var document = await FirebaseFirestore.instance.collection("chatrooms")
        .doc(chatroomId).get();

    //first time chatting
    if (!document.exists) {
      ChatroomModel chatroom = ChatroomModel(
          chatroomId: chatroomId,
          userIds: [studentID, loginUser!.uid],
          lastMessageTimestamp: Timestamp.now(),
      );

      // creates chatroom in firebase
      final firebaseQueries = Get.put(FirebaseQueries());
      firebaseQueries.addChatroom(chatroomId, chatroom);

    }
  }

  String getChatroomId(String userid1, String userid2) {
    if (userid1.hashCode < userid2.hashCode){
      return userid1 + "_" + userid2;
    } else {
      return userid2 + "_" + userid1;
    }
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

                    //main space for messages
                    Expanded(//to make column fit horizontal space
                      child: Padding(//to create some margin around
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            // space for messages
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  StreamBuilder<dynamic>(
                                    stream: messagesQuery,
                                    builder: (BuildContext context,
                                      AsyncSnapshot<dynamic> snapshot) {
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
                                                    child: ListView.builder(
                                                        reverse: true,
                                                        controller: PrimaryScrollController.of(context),
                                                        itemCount: list.length,
                                                        itemBuilder: (context, position) {
                                                          return Material(
                                                            color: Colors.transparent,
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(
                                                                  horizontal: 20, vertical: 8),
                                                              child: Align(
                                                                alignment:
                                                                  list[position]["senderId"] == loginUser!.uid
                                                                      ? Alignment.centerRight
                                                                      : Alignment.centerLeft,
                                                                child: DecoratedBox(
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                        color: list[position]["senderId"] == loginUser!.uid
                                                                            ? Colors.blueAccent
                                                                            : Colors.greenAccent,
                                                                      ),
                                                                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                                                                      color: list[position]["senderId"] == loginUser!.uid
                                                                          ? Colors.blueAccent
                                                                          : Colors.greenAccent,
                                                                  ),
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.symmetric(
                                                                        vertical: 10.0, horizontal: 10.0),
                                                                    child: IntrinsicWidth(
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Column(
                                                                            children: [
                                                                              Text(
                                                                                list[position]["message"]
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Row(
                                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 20),
                                                                                child: Text(
                                                                                  DateFormat("dd/MM/yyyy hh:mm")
                                                                                       .format((list[position]["timestamp"]).toDate()),
                                                                                  style: const TextStyle(fontSize: 10),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                    ),
                                                  ),
                                              )
                                              : const Expanded(child:
                                                  Center(child:
                                                    Text("")
                                                  )
                                                );
                                        }
                                      },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 5,),

                            // typing bar
                            Row(
                              children: [

                                Expanded(
                                  flex: 5,
                                  child: Column(
                                      children: [
                                        TextField(
                                          controller: messageTextController,
                                          onChanged: (value) {
                                            messageTextController.value = TextEditingValue(
                                              text: value.capitalizeFirst.toString(),
                                              selection: TextSelection.fromPosition(
                                                TextPosition(offset: value.length),
                                              ),
                                            );
                                          },
                                          onSubmitted: (String messageText) {
                                            sendMessage(messageText);
                                          },
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.black),
                                          decoration: const InputDecoration(
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
                                            hintText: "nuevo mensaje",
                                            hintStyle: TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                      ]
                                  ),
                                ),

                                const SizedBox(width: 10,),

                                Expanded(
                                  flex: 1,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (messageTextController.text.isNotEmpty) {
                                        var messageText = messageTextController.text;
                                        sendMessage(messageText);
                                      }
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
                                      "Enviar",
                                      style: TextStyle(
                                        color: Colors.white,
                                        letterSpacing: 2,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
      ),

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
                        studentName,
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
