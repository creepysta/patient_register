import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  checkData() async {
    // prefs = await SharedPreferences.getInstance();
    // await DatabaseProvider.dp.dosyncLocal();
    // if(kReleaseMode) {
    //   // if(prefs.getBool('corrected') == null || prefs.getBool('corrected') == false) {
    //     await DatabaseProvider.dp.cc();
    //     await prefs.setBool('corrected', true);
    //   // }
    // }
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkData();
  }

  String _name = 'Name';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.arrow_forward),
            onPressed: () {

            },
          ),
          body: Center(
            // child: CircularProgressIndicator(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    String name;
                    try {
                      final int result =
                          await widget.platform.invokeMethod('backupDb');
                      name = 'Battery level at $result % .';
                    } on PlatformException catch (e) {
                      name = "Failed to get battery level: '${e.message}'.";
                    }

                    setState(() {
                      _name = name;
                    });
                  },
                  // child: Text("Backup Database"),
                  child: Text(_name),
                ),
                RaisedButton(
                  onPressed: () async {
                    String name;
                    try {
                      final int result =
                          await widget.platform.invokeMethod('importDb');
                      name = 'Battery level at $result % .';
                    } on PlatformException catch (e) {
                      name = "Failed to get battery level: '${e.message}'.";
                    }

                    setState(() {
                      _name = name;
                    });
                  },
                  // child: Text("Import Database"),
                  child: Text(_name),
                )
              ],
            ),
          )),
    );
  }
}
