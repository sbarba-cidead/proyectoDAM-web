import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/utilities/variables.dart';


class IncompleteTaskStreamBuilder extends StatefulWidget {

  const IncompleteTaskStreamBuilder({
    Key? key,
  }) : super(key: key);

  @override
  State<IncompleteTaskStreamBuilder> createState() => _IncompleteTaskStreamBuilderState();
}

class _IncompleteTaskStreamBuilderState extends State<IncompleteTaskStreamBuilder> {
  //VARIABLES//
  Stream<QuerySnapshot>? quizStream;

  @override
  void initState() {
    super.initState();

      quizStream = FirebaseFirestore.instance.collection("users")
          .doc(studentID)
          .collection("tasks")
          .where("done", isEqualTo: false).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    //FUNCTIONS//
    // no functions

    return RawScrollbar(
      controller: ScrollController(),
      thumbVisibility: true,
      thumbColor: Colors.primary_dark_transparent,
      radius: const Radius.circular(20),
      thickness: 8,
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
                      width: MediaQuery.of(context).size.width - 250,
                      height: 150,
                      child: ListView.builder(
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
                                  tileColor: Colors.primary_light,
                                  title: Text(
                                    list[position]["content"],
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
                                          'Fecha límite: ${
                                              DateFormat("dd/MM/yyyy")
                                                  .format((list[position]["dueDate"]).toDate())
                                          }',
                                          style: const TextStyle(
                                              color: Colors. white
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                      ),
                  )
                  : const Expanded(child:
                      Center(child:
                        Text("No se han completado tareas.")
                      )
                    );
            }
          },
        ),
      ),
    );
  }
}