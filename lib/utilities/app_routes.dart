import 'package:appletreeweb/app_pages/secondary_pages/new_quiz_page.dart';

import '../app_pages/followup_page.dart';
import '/app_pages/main_page.dart';
import '/app_pages/quizzes_page.dart';
import '/app_pages/settings_page.dart';
import '/app_pages/tasks_page.dart';
import '/app_pages/login_page.dart';
import '../app_pages/secondary_pages/student_followup_page.dart';
import '/app_pages/messages_page.dart';
import '/app_pages/splash_page.dart';
import '/app_pages/secondary_pages/chatroom_page.dart';
import 'package:get/get.dart';

class AppRoutes{

  static String home = "/";
  static String login = "/login";
  static String main = "/main";
  static String quizes = "/quizes";
  static String tasks = "/tasks";
  static String messages = "/messages";
  static String chatroom = "/chatroom";
  static String followup = "/followup";
  static String studentFollowup = "/studentFollowup";
  static String settings = "/settings";
  static String createEditQuiz = "/createEditQuiz";


  static String getHomeRoute() => home;
  static String getLoginRoute() => login;
  static String getMainRoute() => main;
  static String getQuizesRoute() => quizes;
  static String getTasksRoute() => tasks;
  static String getMessagesRoute() => messages;
  static String getChatroomRoute() => chatroom;
  static String getFollowupRoute() => followup;
  static String getStudentFollowupRoute() => studentFollowup;
  static String getSettingsRoute() => settings;
  static String getCreateEditQuizRoute() => createEditQuiz;



  static List<GetPage> routes = [
      GetPage(
          name: home,
          page: () => const SplashPage(),
          transitionDuration: const Duration(seconds: 0)),
      GetPage(
          name: login,
          page: () => const LoginPage(),
          transitionDuration: const Duration(seconds: 0)),
      GetPage(
          name: main,
          page: () => const MainPage(),
          transitionDuration: const Duration(seconds: 0)),
      GetPage(
          name: quizes,
          page: () => const QuizesPage(),
          transitionDuration: const Duration(seconds: 0)),
      GetPage(
          name: tasks,
          page: () => const TasksPage(),
          transitionDuration: const Duration(seconds: 0)),
      GetPage(
          name: messages,
          page: () => const MessagesPage(),
          transitionDuration: const Duration(seconds: 0)),
      GetPage(
          name: chatroom,
          page: () => const ChatroomPage(),
          transitionDuration: const Duration(seconds: 0)),
      GetPage(
          name: followup,
          page: () => const FollowupPage(),
          transitionDuration: const Duration(seconds: 0)),
      GetPage(
          name: studentFollowup,
          page: () => const StudentFollowupPage(),
          transitionDuration: const Duration(seconds: 0)),
      GetPage(
          name: settings,
          page: () => const SettingsPage(),
          transitionDuration: const Duration(seconds: 0)),
      GetPage(
          name: createEditQuiz,
          page: () => const NewQuizPage(),
          transitionDuration: const Duration(seconds: 0)),
      ];
}