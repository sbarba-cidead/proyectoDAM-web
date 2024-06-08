import 'package:firebase_auth/firebase_auth.dart';

String currentScreen = "main"; //pantalla que se está visualizando

late User? loginUser; //usuario profesor que ha iniciado sesión
String username = "";

String studentID = ""; //estudiante seleccionado en mensajes o seguimiento
String studentName = ""; //estudiante seleccionado en mensajes o seguimiento

late Map<String, String> classGroupsMap; //ID-NAME. se crea en mainpage a partir de firebase


Map<String, String> subjects = { //asignaturas disponibles para creación de tests
  "geography" : "geografía",
  "english" : "inglés",
  "maths" : "matemáticas",
  "science" : "ciencia",
  "history" : "historia",
  "literature" : "literatura",
};

Map<String, String> levels = { //niveles disponibles para creación de tests
  "normal" : "normal",
  "review" : "refuerzo",
  "advance" : "avanzado",
};