import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patient_register/globals.dart';
import 'package:patient_register/medicine.dart';
import 'package:patient_register/patient.dart';
import 'package:patient_register/splash.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';

class DatabaseProvider {
  DatabaseProvider._();
  static final DatabaseProvider dp = DatabaseProvider._();
  static final Map creds = {
    "MONGO_USER": "cheesy",
    "MONGO_PASSWORD": "3u4DEsDqlLxVnANK",
    "MONGO_DB": kReleaseMode ? "akum-register" : "test-register"
  };
  static Database _db;
  static Db _mongodb;
  Future<Database> get database async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db;
  }

  Future<Db> get mongodb async {
    if (_mongodb == null) {
      _mongodb = new Db.pool([
        // "mongodb+srv://${creds['MONGO_USER']}:${creds['MONGO_PASSWORD']}@cluster0-bxg3r.mongodb.net/${creds['MONGO_DB']}?retryWrites=true&w=majority",
        "mongodb://${creds['MONGO_USER']}:${creds['MONGO_PASSWORD']}@cluster0-shard-00-00-bxg3r.mongodb.net:27017/${creds['MONGO_DB']}?replicaSet=Cluster0-shard-0&authSource=admin&retryWrites=true&w=majority",
        "mongodb://${creds['MONGO_USER']}:${creds['MONGO_PASSWORD']}@cluster0-shard-00-01-bxg3r.mongodb.net:27017/${creds['MONGO_DB']}?replicaSet=Cluster0-shard-0&authSource=admin&retryWrites=true&w=majority",
        "mongodb://${creds['MONGO_USER']}:${creds['MONGO_PASSWORD']}@cluster0-shard-00-02-bxg3r.mongodb.net:27017/${creds['MONGO_DB']}?replicaSet=Cluster0-shard-0&authSource=admin&retryWrites=true&w=majority"
      ]);
      await _mongodb.open(secure: true);
    }
    return _mongodb;
  }

  Future<Database> _initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "register.db");
    // String path = join(await getDatabasesPath(), "register.db");
    // File prevFile = File(prevPath);
    // if (prevFile.existsSync()) {
    //   File currFile = File(path);
    //   currFile.writeAsBytesSync(prevFile.readAsBytesSync());
    // }
    // prevFile.deleteSync();
    // deleteDatabase(path);
    final Database db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.rawQuery(
          'CREATE TABLE `patient` ( id integer primary key autoincrement, pid integer, name varchar(100), `last-medicine` varchar(30), `last-dose` varchar(10), `last-date` datetime )');
      await db.rawQuery(
          'CREATE TABLE `medicine` ( id integer primary key autoincrement, pid integer, medicine varchar(30), dose varchar(10), `visit-date` datetime )');
    });
    return db;
  }

  Future<String> test() async {
    // String prevPath = join((await getApplicationDocumentsDirectory()).path, "prev.txt");
    // String path = join(await getDatabasesPath(), "curr.txt");
    // File _prevFile = File(prevPath);
    // File _currFile = File(path);
    // _prevFile.writeAsStringSync("previous file");
    // print("before\n");
    // print("from prevFile ${_prevFile.existsSync().readAsStringSync()}");
    // // print("from currFile ${_currFile.readAsStringSync()}");
    // if (_prevFile != null) {
    //   _currFile.writeAsBytesSync(_prevFile.readAsBytesSync());
    // }
    // _prevFile.deleteSync();
    // print("after\n");
    // // print("from prevFile ${_prevFile.readAsStringSync()}");
    // print("from currFile ${_currFile.readAsStringSync()}");
    Directory check = await getExternalStorageDirectory();
    print(check.path);
    return "ok";
  }

  Future<void> newMed({int pid, String medicine, String dose}) async {
    DateTime currTime = DateTime.now();
    String date = currTime.toIso8601String();
    Medicine med =
        new Medicine(pid: pid, medicine: medicine, dose: dose, date: date);
    Database db = await this.database;
    await db.insert('`medicine`', med.toJson());
    await db.update('`patient`',
        {'`last-medicine`': medicine, '`last-dose`': dose, '`last-date`': date},
        where: 'pid=?', whereArgs: [pid]);
    return;
  }

  Future<void> newPatient(
      {String name = '', String medicine = '', String dose = ''}) async {
    DateTime currTime = DateTime.now();
    int pid = currTime.millisecondsSinceEpoch;
    String date = currTime.toIso8601String();
    Database db = await this.database;
    Patient patient = new Patient(name: name, pid: pid, lastDate: date);
    patient.setMed = medicine;
    patient.setDose = dose;
    await db.insert('patient', patient.toJson());
    Medicine med =
        new Medicine(pid: pid, medicine: medicine, dose: dose, date: date);
    await db.insert('medicine', med.toJson());
    return;
  }

  Future<void> deletePatient({int pid}) async {
    Database db = await this.database;
    await db.rawQuery('delete from `patient` where pid = ' + pid.toString());
    await db.rawQuery('delete from `medicine` where pid = ' + pid.toString());
    return;
  }

  Future<void> deleteMed(Medicine med) async {
    Database db = await this.database;
    print('------------------delete Med----------------');
    // print(med.toJson());
    await db.rawQuery(
        'delete from `medicine` where pid = ${med.pid} and `visit-date` = "${med.date}" and medicine = "${med.medicine}"');
    List res = await db.rawQuery(
        'select * from `medicine` where pid = ${med.pid} order by `visit-date` desc limit 1');
    print(res);
    if(res.isEmpty) {
      await db.rawQuery('delete from `patient` where pid = ${med.pid}');
    } else {
      await db.update(
          '`patient`',
          {
            '`last-medicine`': res[0]['medicine'],
            '`last-dose`': res[0]['dose'],
            '`last-date`': res[0]['visit-date']
          },
          where: 'pid=?',
          whereArgs: [med.pid]);
    }

    refHome.value = DateTime.now().millisecondsSinceEpoch;
    refMeds.value = DateTime.now().millisecondsSinceEpoch;
    return;
  }

  Future<List<Patient>> search(String name) async {
    Database db = await this.database;
    List res = await db.rawQuery('Select * from `patient` where name like "%' +
        name +
        '%" order by name asc');
    List<Patient> patients = [];
    for (int i = 0; i < res.length; i++) {
      patients.add(Patient.fromJson(res[i]));
    }
    return patients;
  }

  Future<List<Medicine>> getMedsForPatient({int pid}) async {
    Database db = await this.database;
    List<Medicine> retMeds = [];
    List res = await db.rawQuery('Select * from medicine where pid = ' +
        pid.toString() +
        ' order by `visit-date` desc');
    for (int i = 0; i < res.length; i++) {
      Medicine med = new Medicine(
          pid: pid,
          medicine: res[i]['medicine'],
          dose: res[i]['dose'],
          date: res[i]['visit-date']);
      retMeds.add(med);
    }
    return retMeds;
  }

  Future<bool> backup() async {
    // Database db = await this.database;
    // Db mongodb = await this.mongodb;
    // var patientCol = mongodb.collection('patient');
    // String lastbackupdate = prefs.getString('lastbackup') ?? '0000-00-00T00:00:00.000';
    // List records = await db.rawQuery('select * from `patient` where `visit-date` > "' + lastbackupdate + '"');
    // if(!kReleaseMode) print("$lastbackupdate \n$records");
    // if(records!= null) {
    //   if(records.isNotEmpty) {
    //     await patientCol.insertAll(records);
    //   }
    // }
    // prefs.setString('lastbackup', DateTime.now().toIso8601String());
    try {
      Directory rootStore = await getApplicationDocumentsDirectory();
      Directory extStorage = await getExternalStorageDirectory();
      String prevPath = rootStore.path;
      String extPath = extStorage.path;
      String filePath = join(prevPath, "register.db");
      String backupPath = join(extPath, "backup.db");
      File file = File(filePath);
      File backupFile = File(backupPath);
      backupFile.writeAsBytesSync(file.readAsBytesSync());
    } catch (e) {
      print("Error-------------$e");
      return false;
    }
    return true;
  }

  Future<bool> import() async {
    try {
      File file = await FilePicker.getFile();
      Directory rootStore = await getApplicationDocumentsDirectory();
      String dbPath = join(rootStore.path, 'register.db');
      File db = File(dbPath);
      db.writeAsBytesSync(file.readAsBytesSync());
      await prefs.setBool('synced', true);
    } catch (e) {
      print("Error-------------$e");
      return false;
    }
    return true;
  }

  Future<void> dosyncLocal() async {
    String res = prefs.getString('lastbackup');
    if (res == null || res.contains('0000-00-00T00:00:00.000')) {
      downloadNot.value = true;
    } else {
      downloadNot.value = false;
    }
    return;
  }

  Future<void> synclocal() async {
    // Db mongodb = await this.mongodb;
    // var patientCol = mongodb.collection('patient');
    // List res = await patientCol.find().toList();
    // Database db = await this.database;
    // // await db.rawQuery('delete from `patient` where 1');
    // if(!kReleaseMode) print(await patientCol.find().toList());
    // Batch batch = db.batch();
    // for(int i = 0; i < res.length; i++) {
    //   Patient patient = Patient.fromJson(res[i]);
    //   batch.insert('`patient`', patient.toJson());
    // }
    // await batch.commit(noResult: true);
    // prefs.setString('lastbackup', DateTime.now().toIso8601String());
    // downloadNot.value = false;
    return;
  }

  Future<void> wipe() async {
    Database db = await this.database;
    // List patients = await db.rawQuery('select medicine from `medicine` group by pid');
    // print(patients);
    // await db.rawQuery('drop table if exists `patient-register`');
    await db.rawQuery('Delete from `patient` where 1');
    await db.rawQuery('Delete from `medicine` where 1');
    // await prefs.remove('lastbackup');
    return;
  }

  Future<void> dd() async {
    Database db = await this.database;
    Batch batch = db.batch();
    await db.rawQuery('drop table if exists `patient-register`');
    await db.rawQuery(
        'create table `patient-register` ( id integer primary key autoincrement, name varchar(100), medicine varchar(30), dose varchar(10), `visit-date` datetime) ');
    await db.insert('`patient-register`', {
      "name": 'Akum',
      'medicine': 'test med 0',
      'dose': '8 h',
      '`visit-date`': DateTime.now().toIso8601String()
    });
    await db.insert('`patient-register`', {
      "name": 'Akum',
      'medicine': 'test med 1',
      'dose': '8 h',
      '`visit-date`': DateTime.now().toIso8601String()
    });
    await db.insert('`patient-register`', {
      "name": 'Potash',
      'medicine': 'test med 2',
      'dose': '8 h',
      '`visit-date`': DateTime.now().toIso8601String()
    });
    await db.insert('`patient-register`', {
      "name": 'Akum',
      'medicine': 'test med 3',
      'dose': '8 h',
      '`visit-date`': DateTime.now().toIso8601String()
    });
    await db.insert('`patient-register`', {
      "name": 'Potash',
      'medicine': 'test med 4',
      'dose': '8 h',
      '`visit-date`': DateTime.now().toIso8601String()
    });
    await db.insert('`patient-register`', {
      "name": 'Akum',
      'medicine': 'test med 5',
      'dose': '8 h',
      '`visit-date`': DateTime.now().toIso8601String()
    });
    await db.insert('`patient-register`', {
      "name": 'Potash',
      'medicine': 'test med 6',
      'dose': '8 h',
      '`visit-date`': DateTime.now().toIso8601String()
    });
    await batch.commit(noResult: true);
    return;
  }

  Future<void> cc() async {
    Database db = await this.database;
    if (!kReleaseMode) {
      await db.rawQuery(
          'create table `patient-register` ( id integer primary key autoincrement, name varchar(100), medicine varchar(30), dose varchar(10), `visit-date` datetime) ');
      // Batch batch = db.batch();
      List<Map<String, dynamic>> data = [
        {
          "name": "test 1",
          "medicine": "test 3",
          "dose": "8 h",
          "`visit-date`": DateTime.now().toIso8601String()
        },
        {
          "name": "test 0",
          "medicine": "test 6",
          "dose": "8 h",
          "`visit-date`": DateTime.now().toIso8601String()
        },
        {
          "name": "test 0",
          "medicine": "test 1",
          "dose": "8 h",
          "`visit-date`": DateTime.now().toIso8601String()
        },
        {
          "name": "test 1",
          "medicine": "test 4",
          "dose": "8 h",
          "`visit-date`": DateTime.now().toIso8601String()
        },
        {
          "name": "test 0",
          "medicine": "test 2",
          "dose": "8 h",
          "`visit-date`": DateTime.now().toIso8601String()
        },
        {
          "name": "test 1",
          "medicine": "test 5",
          "dose": "8 h",
          "`visit-date`": DateTime.now().toIso8601String()
        },
        {
          "name": "test 0",
          "medicine": "test 0",
          "dose": "8 h",
          "`visit-date`": DateTime.now().toIso8601String()
        },
      ];
      for (var dd in data) {
        // batch.insert('`patient-register`', dd);
        await db.insert('`patient-register`', dd);
      }
      // await batch.commit(noResult: true);
    } else {
      await db.rawQuery('drop table if exists `patient`');
      await db.rawQuery('drop table if exists `medicine`');
      await db.rawQuery(
          'CREATE TABLE `patient` ( id integer primary key autoincrement, pid integer, name varchar(100), `last-medicine` varchar(30), `last-dose` varchar(10), `last-date` datetime )');
      await db.rawQuery(
          'CREATE TABLE `medicine` ( id integer primary key autoincrement, pid integer, medicine varchar(30), dose varchar(10), `visit-date` datetime )');
      await ss();
      await db.rawQuery('drop table if exists `patient-register`');
    }
    return;
  }

  Future<void> ss() async {
    Database db = await this.database;
    // Batch batch = db.batch();
    List res = await db.rawQuery(
        'select * from `patient-register` order by name asc'); //order by `visit-date` desc
    print('-------------ss---------------');
    // res.forEach((e) => print(e['medicine']));
    const int interval = 1000000000 + 7;
    {
      int pid = DateTime.now().microsecondsSinceEpoch % interval;
      int i = 0;
      for (i = 0; i < res.length - 1; i++) {
        Map<String, dynamic> meds = {
          'pid': pid,
          'medicine': res[i]['medicine'],
          'dose': res[i]['dose'],
          '`visit-date`': res[i]['visit-date'],
        };
        // batch.insert('medicine', meds);
        await db.insert('medicine', meds);
        if (res[i]['name'].toString().trim().toLowerCase().compareTo(
                res[i + 1]['name'].toString().trim().toLowerCase()) !=
            0) {
          Map<String, dynamic> pvs = {
            "pid": pid,
            "name": res[i]['name'],
            "`last-medicine`": res[i]['medicine'],
            "`last-dose`": res[i]['dose'],
            "`last-date`": res[i]['visit-date'],
          };
          // batch.insert('patient', pvs);
          await db.insert('patient', pvs);
          pid = DateTime.now().millisecondsSinceEpoch % interval;
        }
      }
      Map<String, dynamic> meds = {
        'pid': pid,
        'medicine': res[i]['medicine'],
        'dose': res[i]['dose'],
        '`visit-date`': res[i]['visit-date'],
      };
      // batch.insert('medicine', meds);
      await db.insert('medicine', meds);
      Map<String, dynamic> pvs = {
        "pid": pid,
        "name": res[i]['name'],
        "`last-medicine`": res[i]['medicine'],
        "`last-dose`": res[i]['dose'],
        "`last-date`": res[i]['visit-date'],
      };
      // batch.insert('patient', pvs);
      await db.insert('patient', pvs);
      // await batch.commit(noResult: true);
    }
    // update last medicine
    List um = await db.rawQuery('select * from `patient`');
    print(um);
    for (int i = 0; i < um.length; i++) {
      List om = await db.rawQuery(
          'select * from `medicine` where pid = ${um[i]['pid']} order by `visit-date` desc limit 1');
      // batch.update('patient', {
      //   "`last-medicine`": om[0]['medicine'],
      //   "`last-dose`": om[0]['dose'],
      //   "`last-date`": om[0]['visit-date']
      // }, where: 'pid=?', whereArgs: [um[i]['pid']]);
      await db.update(
          'patient',
          {
            "`last-medicine`": om[0]['medicine'],
            "`last-dose`": om[0]['dose'],
            "`last-date`": om[0]['visit-date']
          },
          where: 'pid=?',
          whereArgs: [um[i]['pid']]);
    }
    // await batch.commit(noResult: true);
  }
}
