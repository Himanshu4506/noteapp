import 'package:flutter/material.dart';
import 'package:noteapp/data/db_connection.dart';
import 'package:noteapp/home_page.dart';
import 'NoteSplashScreen.dart';
import 'RegisterPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    DBHelper db = DBHelper.getInstance;

    return MaterialApp(

      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
