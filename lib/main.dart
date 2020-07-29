import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:patient_register/splash.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TPF",
      theme: ThemeData(
        primaryTextTheme: TextTheme(
          bodyText1: TextStyle(fontSize: 15),
          bodyText2: TextStyle(fontSize: 13),
          headline1: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          headline5: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)
        ),
        primaryColor: Color.fromARGB(255, 78, 194, 212),
        brightness: Brightness.light,
        backgroundColor: Color(0xffefefef),
        textTheme: TextTheme(),
        accentColor: Color.fromARGB(255, 78, 194, 212),
      ),
      debugShowCheckedModeBanner: true,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => Splash(),
      },
    );
  }
}
