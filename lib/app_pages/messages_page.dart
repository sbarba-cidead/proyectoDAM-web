import 'package:get/get.dart';

import '../utilities/app_routes.dart';
import '/utilities/variables.dart';
import '/widgets/leftsidemenu.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';


class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  //VARIABLES
  String classGroupsSelected = "";

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

   @override
  void initState() {
    super.initState();

    classGroupsSelected = classGroupsDropdown.elementAt(0).value.toString();
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

                    //main space
                    Expanded(//to make column fit horizontal space
                      child: Padding(//to create some margin around
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            
                            //selector to choose class group
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.primary_light),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(15),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                          setState(() {
                                            classGroupsSelected = selectedItem!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            //view to show students in the selected group
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    StreamBuilder<QuerySnapshot>(
                                      stream:
                                        FirebaseFirestore.instance.collection("users")
                                          .where("classGroupID", isEqualTo: classGroupsSelected).snapshots(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<QuerySnapshot> snapshot) {
                                        if (snapshot.hasError) {
                                          return const Text(
                                              "Se ha producido un error.");
                                        }
                                                
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(child: CircularProgressIndicator());
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
                                                    child: GridView.builder(
                                                      controller: PrimaryScrollController.of(context),
                                                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                                          maxCrossAxisExtent: 200, //max width for tile
                                                          childAspectRatio: 3 / 2,
                                                          crossAxisSpacing: 20,
                                                          mainAxisSpacing: 20),
                                                      itemCount: list.length,
                                                      itemBuilder: (context, position) {
                                                        return InkWell(
                                                          onTap: () {
                                                            studentID = list[position].id;
                                                            studentName = list[position]["username"];
                                                
                                                            Get.toNamed(AppRoutes.getChatroomRoute());
                                                          },
                                                          child: Material(
                                                            color: Colors.transparent,
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(
                                                                  horizontal: 20, vertical: 8),
                                                              child: GridTile(
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    color: Colors.primary_light,
                                                                  ),
                                                                  child: Center(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(10),
                                                                      child: Text(
                                                                        list[position]["username"],
                                                                        style: const TextStyle(
                                                                          color: Colors. white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ),
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
                                                    Text("No hay alumnos asignados.")
                                                  )
                                              );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
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
      child: const Row(
        children: [
          Expanded(//to make text fit horizontal space
              child: Center(
                  child: Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text(
                        "Mensajes",
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
