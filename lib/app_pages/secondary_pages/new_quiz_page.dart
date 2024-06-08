import '/widgets/formwidget.dart';
import '/widgets/leftsidemenu.dart';

import 'package:flutter/material.dart';


class NewQuizPage extends StatefulWidget {
  const NewQuizPage({super.key});

  @override
  State<NewQuizPage> createState() => _NewQuizPageState();
}

class _NewQuizPageState extends State<NewQuizPage> {

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

                  child: const Column(
                    children: [
                      //titlebar
                      Titlebar(),

                      //main space for quizes
                      Expanded(//to make column fit horizontal space
                        child: Padding(//to create some margin around
                          padding: EdgeInsets.all(40.0),
                          //child: const QuestionForm(),
                          child: FormWidget(),
                        ),
                      ),
                    ],
                  ),
                ),
              )

            ]
        )
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
                        "Tests",
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

