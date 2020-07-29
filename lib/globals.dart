import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';


SharedPreferences prefs;
ValueNotifier<bool> downloadNot = new ValueNotifier(true);
ValueNotifier<int> refHome = new ValueNotifier(0);
ValueNotifier<int> refMeds = new ValueNotifier(0);