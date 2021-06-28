import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebaseStorage;


SharedPreferences prefs;
FirebaseAuth auth;
User user;
firebaseStorage.Reference storageRef;
ValueNotifier<bool> downloadNot = new ValueNotifier(true);
ValueNotifier<int> refHome = new ValueNotifier(0);
ValueNotifier<int> refMeds = new ValueNotifier(0);