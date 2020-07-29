import 'dart:convert';
import 'package:intl/intl.dart';

Medicine medicineFromJson(String str) => Medicine.fromJson(json.decode(str));

String medicineToJson(Medicine data) => json.encode(data.toJson());

class Medicine {
  int pid;
  String medicine;
  String dose;
  String date;

  set setMed(String med) {
    this.medicine = med;
  }

  set setDose(String dose) {
    this.dose = dose;
  }

  Medicine({
    this.pid,
    this.medicine,
    this.dose,
    this.date
  });

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
    pid: json['pid'],
    medicine: json['medicine'].toString(),
    dose: json['dose'].toString(),
    date: json["visit-date"].toString(),
  );

  Map<String, dynamic> toJson() => {
    "pid": pid,
    "medicine": medicine,
    "dose": dose,
    "`visit-date`": date,
  };
}
