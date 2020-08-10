import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:patient_register/globals.dart';
import 'package:patient_register/home.dart';
import 'package:patient_register/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  final MethodChannel platform;
  Splash({this.platform});
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  Future<void> check() async {
    prefs = await SharedPreferences.getInstance();
    // if (prefs.getBool('synced') == true) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home()),
          (Route route) => route == null);
    // }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    check();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          // floatingActionButton: FloatingActionButton(
          //   child: Icon(Icons.arrow_forward),
          //   onPressed: () async {
          //     prefs.setBool('synced', true);
          //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home()), (route) => route == null);
          //   },
          // ),
          body: Center(
            child: CircularProgressIndicator(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            // child: Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: <Widget>[
            //     RaisedButton(
            //       onPressed: () async {
            //         // print(await DatabaseProvider.dp.test());
            //         // try {
            //         // final int result =
            //         //     await widget.platform.invokeMethod('backupDb');
            //         // if (result == 1) {
            //         //   Fluttertoast.showToast(
            //         //       msg: 'Fill all fields',
            //         //       gravity: ToastGravity.BOTTOM,
            //         //       toastLength: Toast.LENGTH_LONG,
            //         //       fontSize: 13,
            //         //       backgroundColor: Colors.black.withOpacity(0.7),
            //         //       textColor: Colors.white);
            //         //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
            //         //   }
            //         // } on PlatformException catch (e) {
            //         //   print(e);
            //         // }
            //       },
            //       child: Text("Backup Database"),
            //     ),
            //     RaisedButton(
            //       onPressed: () async {
            //         // try {
            //         //   final int result =
            //         //       await widget.platform.invokeMethod('importDb');
            //         // } on PlatformException catch (e) {}
            //       },
            //       child: Text("Import Database"),
            //     )
            //   ],
            // ),
          )),
    );
  }
}
