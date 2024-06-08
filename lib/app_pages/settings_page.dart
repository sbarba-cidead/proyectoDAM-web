import 'package:appletreeweb/utilities/variables.dart';
import 'package:get/get.dart';

import '/widgets/leftsidemenu.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  //VARIABLES//
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();

  bool hidePassword = true;
  //END OF VARIABLES//

  //FUNCTIONS//

  changePasswordVisibility() {
    setState(() {
      hidePassword = !hidePassword;
    });    
  }

  resetAllWidgets(BuildContext context) {
    void rebuild(Element e) {
      e.markNeedsBuild();
      e.visitChildren(rebuild);
    }
    (context as Element).visitChildren(rebuild);
  }

  bool checkEmptyTextfield(String textfieldName, String textfieldContent) {
    if (textfieldContent.isEmpty) {
      Get.snackbar("", "",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.primary_dark_transparent,
              titleText: const SizedBox(),
              messageText: Center(
                  child: Text(
                    "El campo de cambio de $textfieldName no puede estar vacío.",
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  )),
              margin: const EdgeInsets.all(30),
              isDismissible: false,
            );
    }

    return textfieldContent.isEmpty;
  }

  showReloginDialog(String inputTextName, TextEditingController inputTextController) {
    //asks for old password
    showDialog(
        context: context,
        builder: (BuildContext context) {
          bool hidePasswordDialog = true;
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: const Text("Confirmar contraseña"),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField( //textfield for quiz name
                        controller: oldPasswordController,
                        obscureText: hidePasswordDialog,
                        onSubmitted: (String text){
                          acceptDialog(oldPasswordController, 
                            inputTextController, inputTextName);                                     
                        },
                        decoration: InputDecoration(
                            hintText: "contraseña actual",
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: IconButton(
                                icon: Icon(
                                  hidePasswordDialog
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    hidePasswordDialog = !hidePasswordDialog;
                                  });    
                                }
                              ),
                            )
                        ),
                      ),
                    ]
                  ),
                actions: <Widget>[
                  TextButton( //cancel button
                    child: const Text('Cancelar'),
                    onPressed: () {
                      Get.snackbar("", "",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.primary_dark_transparent,
                        titleText: const SizedBox(),
                        messageText: Center(
                            child: Text(
                              "Se ha cancelado el cambio de $inputTextName.",
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            )),
                        margin: const EdgeInsets.all(30),
                        isDismissible: false,
                      );

                      oldPasswordController.clear();
                      oldPasswordController.clear;
                      inputTextController.clear();
                      inputTextController.clear;

                      //closes dialog
                      Navigator.pop(context);
                    },
                  ),
                  TextButton( //save button
                    child: const Text('Aceptar'),
                    onPressed: () async {
                      acceptDialog(oldPasswordController, 
                        inputTextController, inputTextName);
                    },
                  ),
                ],
              );
            },
          );
        },
      );
  
  }

  acceptDialog(TextEditingController dialogController, TextEditingController inputTextController,
    String inputTextName) async {
    if (dialogController.text.isNotEmpty) {
      if(await tryRelogin()) {
        if (inputTextName == "nombre de usuario") {
          changeUsername(inputTextController.text);
        } else if (inputTextName == "email") {
          changeEmail(inputTextController.text);
        } else if (inputTextName == "contraseña") {
          changePassword(inputTextController.text);
        }

        dialogController.clear();
        dialogController.clear;
        inputTextController.clear();
        inputTextController.clear;

        //closes dialog
        Navigator.pop(context);
      }
    } else {
      // shows error message
      Get.snackbar("", "",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.primary_dark_transparent,
        titleText: const SizedBox(),
        messageText: const Center(
            child: Text(
              "El campo de contraseña no puede estar vacío.",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            )),
        margin: const EdgeInsets.all(30),
        isDismissible: false,
      );
    }
  }
  
  Future<bool> tryRelogin() async {
    bool correctRelogin = true;

    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: loginUser!.email.toString(),
        password: oldPasswordController.text,
    ).catchError((error){
      // shows error message
      Get.snackbar("", "",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.primary_dark_transparent,
        titleText: const SizedBox(),
        messageText: const Center(
            child: Text(
              "Contraseña incorrecta. Inténtalo de nuevo.",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            )),
        margin: const EdgeInsets.all(30),
        isDismissible: false,
      );

      correctRelogin = false;

      return error;
    });

    return correctRelogin;
  }

  changeUsername(String newUsername) async {
    await FirebaseFirestore.instance.collection('admins')
      .doc(loginUser!.uid).update({'name': newUsername}).then((a){
        username = newUsername;

        resetAllWidgets(context);

        Get.snackbar("", "",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.primary_dark_transparent,
          titleText: const SizedBox(),
          messageText: const Center(
              child: Text(
                "El nombre de usuario se ha cambiado correctamente.",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              )),
          margin: const EdgeInsets.all(30),
          isDismissible: false,
        );                          
      }).catchError((error){
        // shows error message
        Get.snackbar("", "",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.primary_dark_transparent,
          titleText: const SizedBox(),
          messageText: const Center(
              child: Text(
                "Se ha producido un error. Inténtalo de nuevo.",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              )),
          margin: const EdgeInsets.all(30),
          isDismissible: false,
        );
    });
  }

  changeEmail(String newEmail) async {
    await loginUser!.updateEmail(newEmail).then((a) async {
      await FirebaseFirestore.instance.collection('admins')
      .doc(loginUser!.uid).update({'email': newEmail}).then((a) {
        Get.snackbar("", "",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.primary_dark_transparent,
          titleText: const SizedBox(),
          messageText: const Center(
              child: Text(
                "La dirección email se ha cambiado correctamente.",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              )),
          margin: const EdgeInsets.all(30),
          isDismissible: false,
        );
      });
    }).catchError((error){
      // shows error message
      Get.snackbar("", "",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.primary_dark_transparent,
        titleText: const SizedBox(),
        messageText: const Center(
            child: Text(
              "Se ha producido un error. Inténtalo de nuevo.",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            )),
        margin: const EdgeInsets.all(30),
        isDismissible: false,
      );
    });
  }

  changePassword(String newPassword) async {
    await loginUser!.updatePassword(newPassword).then((a){
      Get.snackbar("", "",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.primary_dark_transparent,
        titleText: const SizedBox(),
        messageText: const Center(
            child: Text(
              "La contraseña se ha cambiado correctamente.",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            )),
        margin: const EdgeInsets.all(30),
        isDismissible: false,
      );
    }).catchError((error){
      // shows error message
      Get.snackbar("", "",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.primary_dark_transparent,
        titleText: const SizedBox(),
        messageText: const Center(
            child: Text(
              "Se ha producido un error. Inténtalo de nuevo.",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            )),
        margin: const EdgeInsets.all(30),
        isDismissible: false,
      );
    });
  }

  LeftsideMenu cosa = const LeftsideMenu();

  //END OF FUNCTIONS//

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
          children: [

            //left sidebar
            cosa,

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

                    //main space for settings
                    Expanded(//to make column fit horizontal space
                      child: Padding(//to create some margin around
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            
                            //change username
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 400,
                                  child: Column(
                                    children: [
                                      //change username label
                                      const Text(
                                        "Nuevo nombre de usuario:",
                                        style: TextStyle(
                                          fontSize: 18, color: Colors.black,
                                        )
                                      ),
                                                            
                                      const SizedBox(height: 20,),
                                      
                                      //change username textfield
                                      TextField(
                                        controller: usernameController,
                                        onSubmitted: (String text){
                                          //if textfield is not empty
                                          if(!checkEmptyTextfield("nombre de usuario", text)) {
                                            showReloginDialog("nombre de usuario", usernameController);
                                          }                                          
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
                                              hintText: "Nombre de usuario",
                                          hintStyle: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                                            
                                      const SizedBox(height: 20,),
                                                            
                                      //change username confirm bottom
                                      ElevatedButton(
                                        onPressed: (){
                                          //if textfield is not empty
                                          if(!checkEmptyTextfield("nombre de usuario", usernameController.text)) {
                                            showReloginDialog("nombre de usuario", usernameController);
                                          }                                          
                                        },
                                        onHover: (value){},
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all(
                                              const EdgeInsets.symmetric(
                                                horizontal: 50,
                                                vertical: 20,
                                              )
                                          ),
                                          foregroundColor: MaterialStateProperty.all(
                                            Colors.primary_dark,
                                          ),
                                          backgroundColor: MaterialStateProperty.all(
                                            Colors.primary_dark,
                                          ),
                                          //hover and pressed effects
                                          overlayColor: MaterialStateProperty.resolveWith(
                                                (Set<MaterialState> states) {
                                              if (states.contains(MaterialState.hovered)) {
                                                return Colors.blueGrey; //if button is hovered
                                              } else if (states.contains(MaterialState.pressed)) {
                                                return Colors.primary_light; //if button is pressed
                                              } else {
                                                return null; // default color
                                              }
                                            },
                                          ),
                                        ),
                                        child: const Text(
                                          "Aceptar",
                                          style: TextStyle(
                                            color: Colors.white,
                                            letterSpacing: 2,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                                            
                                  ]),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 60,),

                            //change email and password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 400,
                                  child: Column(
                                    children: [
                                      //change email label
                                      const Text(
                                        "Nueva dirección email:",
                                        style: TextStyle(
                                          fontSize: 18, color: Colors.black,
                                        )
                                      ),
                                
                                      const SizedBox(height: 20,),
                                  
                                      //change email textfield
                                      TextField(
                                        controller: emailController,
                                        onSubmitted: (String text){
                                          //if textfield is not empty
                                          if(!checkEmptyTextfield("email", text)) {
                                            showReloginDialog("email", emailController);
                                          }                                          
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
                                          hintText: "Dirección email",
                                          hintStyle: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                
                                      const SizedBox(height: 20,),
                                
                                      //change email confirm bottom
                                      ElevatedButton(
                                        onPressed: (){
                                          //if textfield is not empty
                                          if(!checkEmptyTextfield("email", emailController.text)) {
                                            showReloginDialog("email", emailController);
                                          }
                                        },
                                        onHover: (value){},
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all(
                                              const EdgeInsets.symmetric(
                                                horizontal: 50,
                                                vertical: 20,
                                              )
                                          ),
                                          foregroundColor: MaterialStateProperty.all(
                                            Colors.primary_dark,
                                          ),
                                          backgroundColor: MaterialStateProperty.all(
                                            Colors.primary_dark,
                                          ),
                                          //hover and pressed effects
                                          overlayColor: MaterialStateProperty.resolveWith(
                                                (Set<MaterialState> states) {
                                              if (states.contains(MaterialState.hovered)) {
                                                return Colors.blueGrey; //if button is hovered
                                              } else if (states.contains(MaterialState.pressed)) {
                                                return Colors.primary_light; //if button is pressed
                                              } else {
                                                return null; // default color
                                              }
                                            },
                                          ),
                                        ),
                                        child: const Text(
                                          "Aceptar",
                                          style: TextStyle(
                                            color: Colors.white,
                                            letterSpacing: 2,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 20,),

                                SizedBox(
                                  width: 400,
                                  child: Column(
                                    children: [
                                      //change password label
                                      const Text(
                                        "Nueva contraseña:",
                                        style: TextStyle(
                                          fontSize: 18, color: Colors.black,
                                        )
                                      ),
                                
                                      const SizedBox(height: 20,),
                                
                                      //change password textfield
                                      TextField(
                                        controller: passwordController,
                                        obscureText: hidePassword,
                                        onSubmitted: (String text){
                                          //if textfield is not empty
                                          if(!checkEmptyTextfield("contraseña", text)) {
                                            showReloginDialog("contraseña", passwordController);
                                          }                                          
                                        },
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.black),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          enabledBorder: const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                                width: 2,
                                              )),
                                          focusedBorder: const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.orange,
                                                width: 2,
                                              )),
                                          hintText: "Contraseña",
                                          hintStyle: const TextStyle(color: Colors.grey),
                                          suffixIcon: Padding(
                                            padding: const EdgeInsets.only(right: 5),
                                            child: IconButton(
                                              icon: Icon(
                                                hidePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                                color: Colors.grey,
                                              ),
                                              onPressed: changePasswordVisibility
                                            ),
                                          )
                                        ),
                                      ),
                                
                                      const SizedBox(height: 20,),
                                
                                      //change password confirm bottom
                                      ElevatedButton(
                                        onPressed: (){
                                          //if textfield is not empty
                                          if(!checkEmptyTextfield("contraseña", passwordController.text)) {
                                            showReloginDialog("contraseña", passwordController);
                                          } 
                                        },
                                        onHover: (value){},
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all(
                                              const EdgeInsets.symmetric(
                                                horizontal: 50,
                                                vertical: 20,
                                              )
                                          ),
                                          foregroundColor: MaterialStateProperty.all(
                                            Colors.primary_dark,
                                          ),
                                          backgroundColor: MaterialStateProperty.all(
                                            Colors.primary_dark,
                                          ),
                                          //hover and pressed effects
                                          overlayColor: MaterialStateProperty.resolveWith(
                                                (Set<MaterialState> states) {
                                              if (states.contains(MaterialState.hovered)) {
                                                return Colors.blueGrey; //if button is hovered
                                              } else if (states.contains(MaterialState.pressed)) {
                                                return Colors.primary_light; //if button is pressed
                                              } else {
                                                return null; // default color
                                              }
                                            },
                                          ),
                                        ),
                                        child: const Text(
                                          "Aceptar",
                                          style: TextStyle(
                                            color: Colors.white,
                                            letterSpacing: 2,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                                                
                                    ],
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
      child: const Row(
        children: [
          Expanded(//to make text fit horizontal space
              child: Center(
                  child: Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text(
                        "Ajustes",
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
