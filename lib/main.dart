import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:patient_register/splash.dart';

void main() { //async { 
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const MethodChannel platform = const MethodChannel('samples.flutter.dev/battery');
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Patient Register",
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
        '/splash': (context) => Splash(platform: platform),
      },
    );
  }
}
