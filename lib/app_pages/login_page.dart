import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/utilities/variables.dart';
import '/utilities/app_routes.dart';
import '/firebase/firebase_queries.dart';

import 'package:get/get.dart';
import 'package:flutter/material.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final firebaseQueries = Get.put(FirebaseQueries());

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordRecoveryController = TextEditingController();

  bool hidePassword = true;

  //FUNCTIONS//

  changePasswordVisibility() {
    setState(() {
      hidePassword = !hidePassword;
    });    
  }

  passwordRecovery(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email)
        .then((a) {
      Get.snackbar("", "",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.primary_dark_transparent,
        titleText: const SizedBox(),
        messageText: const Center(
            child: Text(
              "Se ha enviado un email de recuperación.",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            )),
        margin: const EdgeInsets.all(30),
        isDismissible: false,
      );
    })
        .catchError((a) {
      Get.snackbar("", "",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.primary_dark_transparent,
        titleText: const SizedBox(),
        messageText: const Center(
            child: Text(
              "Se ha producido un error\nInténtalo de nuevo más tarde.",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            )),
        margin: const EdgeInsets.all(30),
        isDismissible: false,
      );
    });
  }

  showPasswordRecoveryDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                    title: const Text("Recuperación de contraseña"),
                    content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField( //textfield for quiz name
                            controller: passwordRecoveryController,
                            onSubmitted: (a) {
                              if (passwordRecoveryController.text.isNotEmpty) {
                                passwordRecovery(passwordRecoveryController.text);

                                //closes dialog
                                Navigator.pop(context);
                              } else {
                                // shows error message
                                Get.snackbar("", "",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.primary_dark_transparent,
                                  titleText: const SizedBox(),
                                  messageText: const Center(
                                      child: Text(
                                        "Error: Debe indicar una dirección email.",
                                        style: TextStyle(color: Colors.white),
                                        textAlign: TextAlign.center,
                                      )),
                                  margin: const EdgeInsets.all(30),
                                  isDismissible: false,
                                );
                              }
                            },
                            decoration: const InputDecoration(
                                hintText: "Dirección email"
                            ),
                          ),
                        ]
                    ),
                    actions: <Widget>[
                      TextButton( //cancel button
                        child: const Text('Cancelar'),
                        onPressed: () {
                          //closes dialog
                          Navigator.pop(context);
                        },
                      ),
                      TextButton( //save button
                        child: const Text('Aceptar'),
                        onPressed: () {
                          if (passwordRecoveryController.text.isNotEmpty) {
                            passwordRecovery(passwordRecoveryController.text);

                            //closes dialog
                            Navigator.pop(context);
                          } else {
                            // shows error message
                            Get.snackbar("", "",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.primary_dark_transparent,
                              titleText: const SizedBox(),
                              messageText: const Center(
                                  child: Text(
                                    "Error: Debe indicar una dirección email.",
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  )),
                              margin: const EdgeInsets.all(30),
                              isDismissible: false,
                            );
                          }
                        },
                      ),
                    ],
                );
              }
          );
        }
    );
  }

  login() async {
    var loginSuccessful = await firebaseQueries.tryLogin(usernameController.text,
                                                         passwordController.text);
    if (loginSuccessful) { //if the username is admin
      //saves current login user
      loginUser = FirebaseAuth.instance.currentUser;

      //gets current login username
      await FirebaseFirestore.instance
          .collection("admins").doc(loginUser!.uid).get().then((documentSnapshot) {
          username = documentSnapshot.get("name");
      });

      //goes to the main screen of the web
      Get.offNamed(AppRoutes.getMainRoute());
    }
  }

  //END OF FUNCTIONS//

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //Background
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),

        child: Stack(
          children: [
            Center(
              //Main container
              child: SizedBox(
                // //Container size will take 50% of screen size
                // width: MediaQuery.of(context).size.width * .5, //50%
                width: 400,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Logo
                    Image.asset(
                      "assets/images/appletree_logo.png",
                      height: 150.0,
                      width: 150.0,
                    ),

                    const SizedBox(height: 30,),

                    //User name input
                    TextField(
                      controller: usernameController,
                      onSubmitted: (String text) {
                        login();
                      },
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 2,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.orange,
                              width: 2,
                            )
                        ),
                        hintText: "nombre usuario",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),

                    const SizedBox(height: 15,),

                    //Password input
                    TextField(
                      controller: passwordController,
                      onSubmitted: (String text) {
                        login();
                      },
                      obscureText: hidePassword,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 2,
                            )
                        ),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.orange,
                              width: 2,
                            )
                        ),
                        hintText: "contraseña",
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

                    const SizedBox(height: 30,),

                    TextButton(
                      onPressed: () {
                        showPasswordRecoveryDialog();
                      },
                      child: const Text(
                        "Recuperar contraseña",
                          style: TextStyle(
                              color: Colors.white
                          ),
                      ),
                    ),

                    const SizedBox(height: 30,),

                    //Login button
                    ElevatedButton(
                      onPressed: (){
                        login();
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
                        "Iniciar sesión",
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
            )
          ],
        ),
      ),
    );
  }
}


