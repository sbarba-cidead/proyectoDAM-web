import '/utilities/variables.dart';
import '/widgets/leftsidemenu.dart';
import '/firebase/firebase_queries.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';


class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  //VARIABLES//
  final firebaseQueries = Get.put(FirebaseQueries());

  String buttonText = "Crear";
  TextEditingController contentController = TextEditingController();
  TextEditingController dueDateController = TextEditingController();

  Timestamp? timestampDate;
  String taskID = "";

  String classGroupsSelected = "";
  String classGroupsSelectedName = "";
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

  //FUNCTIONS//

  saveTask() {
    firebaseQueries.createTask(
        contentController.text,
        timestampDate!, classGroupsSelected, classGroupsSelectedName);
  }

  editTask() {
    firebaseQueries.editTask(
        taskID,
        contentController.text,
        timestampDate!, classGroupsSelected, classGroupsSelectedName);
  }

  Future<DateTime?> showDateTimePicker({
    required BuildContext context, required Locale locale,
    DateTime? initialDate, DateTime? firstDate, DateTime? lastDate}) async {

    initialDate ??= DateTime.now();
    firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
    lastDate ??= firstDate.add(const Duration(days: 365 * 200));

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      locale: locale,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate == null) return null;

    if (!context.mounted) return selectedDate;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    return selectedTime == null
        ? selectedDate
        : DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
  }

  showConfirmDialog(String taskID) {
    //asks for old password
    showDialog(
        context: context,
        builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Confirmar borrado"),
                content: const Text("¿Seguro que quieres borrar la tarea? No se podrá recuperar."),
                actions: <Widget>[
                  TextButton( //cancel button
                    child: const Text('Cancelar'),
                    onPressed: () {
                      Get.snackbar("", "",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.primary_dark_transparent,
                        titleText: const SizedBox(),
                        messageText: const Center(
                            child: Text(
                              "Borrado de tarea cancelado.",
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            )),
                        margin: const EdgeInsets.all(30),
                        isDismissible: false,
                      );

                      //closes dialog
                      Navigator.pop(context);
                    },
                  ),
                  TextButton( //save button
                    child: const Text('Borrar'),
                    onPressed: () async {
                      //deletes task
                      firebaseQueries.removeTask(taskID);

                      //closes dialog
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
        },
      );
  }  

  //END OF FUNCTIONS//

  @override
  void initState() {
    super.initState();

    classGroupsSelected = classGroupsDropdown.elementAt(0).value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [

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

                //main space
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [

                        //create new tasks
                        Row(
                          children: [

                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  TextField(
                                    controller: contentController,
                                    onChanged: (value) {
                                      contentController.value = TextEditingValue(
                                        text: value.capitalizeFirst.toString(),
                                        selection: TextSelection.fromPosition(
                                          TextPosition(offset: value.length),
                                        ),
                                      );
                                    },
                                    style: const TextStyle(
                                        height: 2, fontSize: 14, color: Colors.black),
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
                                      hintText: "nueva tarea",
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ]
                              ),
                            ),

                            const SizedBox(width: 10,),

                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Container(decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors.grey,
                                        width: 2
                                    ),

                                  ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          labelText: 'Clase y grupo',
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                        ),
                                        isExpanded: true,
                                        value: classGroupsSelected,
                                        items: classGroupsDropdown,
                                        onChanged: (String? selectedItem) {
                                            classGroupsSelected = selectedItem!;
                                            classGroupsSelectedName = classGroupsMap[selectedItem]!;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 10,),

                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  TextField(
                                    controller: dueDateController,
                                    style: const TextStyle(
                                      height: 2, fontSize: 14, color: Colors.black
                                    ),
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
                                      hintText: "fecha límite",
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                    readOnly: true,
                                    onTap: () async {
                                      DateTime? pickedDate = await showDateTimePicker(
                                        context: context,
                                        locale: const Locale("es", "ES"),
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2100)
                                      );
                                      if(pickedDate != null){
                                        timestampDate = Timestamp.fromDate(pickedDate);
                                        String formattedDate = DateFormat("dd/MM/yyyy HH:mm").format(pickedDate);
                                        dueDateController.text = formattedDate;
                                      }
                                    }
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 20,),

                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  if(contentController.text.isNotEmpty &&
                                      dueDateController.text.isNotEmpty){

                                    if (buttonText == "Crear") {
                                      saveTask();
                                    } else {
                                      editTask();
                                      setState(() {
                                        buttonText == "Crear";
                                      });
                                    }

                                    contentController.clear();
                                    contentController.clear;
                                    dueDateController.clear();
                                    dueDateController.clear;
                                  } else if (contentController.text.isEmpty) {
                                    Get.snackbar("", "",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.primary_dark_transparent,
                                      titleText: const SizedBox(),
                                      messageText: const Center(
                                          child: Text(
                                            "Debe indicar el contenido de la tarea.",
                                            style: TextStyle(color: Colors.white),
                                            textAlign: TextAlign.center,
                                          )),
                                      margin: const EdgeInsets.all(30),
                                      isDismissible: false,
                                    );
                                  } else if (dueDateController.text.isEmpty) {
                                    Get.snackbar("", "",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.primary_dark_transparent,
                                      titleText: const SizedBox(),
                                      messageText: const Center(
                                          child: Text(
                                            "Debe indicar una fecha límite para la tarea.",
                                            style: TextStyle(color: Colors.white),
                                            textAlign: TextAlign.center,
                                          )),
                                      margin: const EdgeInsets.all(30),
                                      isDismissible: false,
                                    );
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
                                child: Text(
                                    buttonText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      letterSpacing: 2,
                                      fontSize: 14,
                                    ),
                                  ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 40,
                        ),

                        //listview showing all created tasks
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              StreamBuilder<QuerySnapshot>(
                                stream:
                                  FirebaseFirestore.instance.collection("tasks")
                                    .doc(loginUser!.uid).collection("tasks")
                                    .orderBy("createdDate", descending: true).snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
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
                                            controller: PrimaryScrollController.of(context),
                                            itemCount: list.length,
                                            itemBuilder: (context, position) {
                                              return Material(
                                                  color: Colors.transparent,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 20, vertical: 8),
                                                    child: ListTile(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                20),
                                                      ),
                                                      tileColor: Colors.primary_light,
                                                      title: Text(
                                                        list[position]["content"],
                                                        style: const TextStyle(
                                                            color: Colors. white
                                                        ),
                                                      ),
                                                      subtitle: Row(
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 20),
                                                            child: Text(
                                                              'Fecha límite: ${
                                                                  DateFormat("dd/MM/yyyy HH:mm")
                                                                    .format((list[position]["dueDate"]).toDate())
                                                              }',
                                                              style: const TextStyle(
                                                                  color: Colors. white
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 20),
                                                            child: Text(
                                                              'Clase y grupo: ${
                                                                  list[position]["groupName"]
                                                              }',
                                                              style: const TextStyle(
                                                                  color: Colors. white
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      trailing: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          TextButton(
                                                            onPressed: () {
                                                              contentController.text = list[position]["content"];
                                                              dueDateController.text = DateFormat("dd/MM/yyyy")
                                                                                        .format((list[position]["dueDate"]).toDate());
                                                              timestampDate = Timestamp.fromDate((list[position]["dueDate"]).toDate());
                                                              taskID = list[position].id;

                                                              setState(() {
                                                                buttonText = "Editar";
                                                              });
                                                            },
                                                            child: const Icon(
                                                              Icons.edit,
                                                              color: Colors.white,
                                                              size: 25,
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              showConfirmDialog(list[position].id);
                                                            },
                                                            child: const Icon(
                                                              Icons.delete_forever,
                                                              color: Colors.white,
                                                              size: 25,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                            }
                                          ),
                                        ),
                                      )
                                      : const Expanded(child:
                                          Center(child:
                                            Text("No hay tareas creadas.")
                                          )
                                        );
                                  }
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ]),
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
      child: const Row(
        children: [
          Expanded(
              child: Center(
                  child: Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text(
                        "Tareas",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ))))
        ],
      ),
    );
  }
}
