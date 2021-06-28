import 'dart:convert';
import 'package:patient_register/medicine.dart';

Patient patientFromJson(String str) => Patient.fromJson(json.decode(str));

String patientToJson(Patient data) => json.encode(data.toJson());

class Patient {
  // core
  int pid;
  String name;
  String lastDate;
  // others
  String lastDose;
  String lastMedicine;
  List<Medicine> prevMeds;

  set setPrevMeds(List<Medicine> meds) {
    this.prevMeds = meds;
  }

  set setMed(String med) {
    this.lastMedicine = med;
  }

  set setDose(String dose) {
    this.lastDose = dose;
  }

  Patient({
    this.pid,
    this.name,
    this.lastMedicine,
    this.lastDose,
    this.lastDate
  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    pid: json['pid'].runtimeType == String ? int.parse(json['pid']) : json['pid'],
    name: json["name"].toString(),
    lastMedicine: json['last-medicine'].toString(),
    lastDose: json['last-dose'].toString(),
    lastDate: json["last-date"].toString(),
  );

  Map<String, dynamic> toJson() => {
    "pid": pid,
    "name": name,
    "`last-dose`": lastDose,
    "`last-medicine`": lastMedicine,
    "`last-date`": lastDate,
  };
}
