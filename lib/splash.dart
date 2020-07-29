import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:patient_register/globals.dart';
import 'package:patient_register/home.dart';
import 'package:patient_register/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  checkData() async {
    prefs = await SharedPreferences.getInstance();
    // await DatabaseProvider.dp.dosyncLocal();
    // if(kReleaseMode) {
    //   // if(prefs.getBool('corrected') == null || prefs.getBool('corrected') == false) {
    //     await DatabaseProvider.dp.cc();
    //     await prefs.setBool('corrected', true);
    //   // }
    // }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      )
    );
  }
}