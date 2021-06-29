import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:patient_register/globals.dart' as globalVars;
import 'package:patient_register/local_store.dart';
import 'package:patient_register/medicine.dart';
import 'package:patient_register/patient.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

// import 'package:http/http.dart' as http;
// import 'package:googleapis/drive/v3.dart' as drive;
// import 'package:google_sign_in/google_sign_in.dart' as signIn;

// class GoogleAuthClient extends http.BaseClient {
//   final Map<String, String> _headers;

//   final http.Client _client = new http.Client();

//   GoogleAuthClient(this._headers);

//   Future<http.StreamedResponse> send(http.BaseRequest request) {
//     return _client.send(request..headers.addAll(_headers));
//   }
// }

class Home extends StatefulWidget {
    @override
    _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
    List<Patient> patients = [];
    bool _hasSearched = false;
    final TextEditingController nameController = new TextEditingController();
    IconData syncIcon;

    // Method Channel
    static const platform =
            const MethodChannel('com.example.patient_register/service');

    @override
    void initState() {
        super.initState();
        globalVars.refHome.addListener(() async {
            if (_hasSearched) {
                patients.clear();
                List res = await DatabaseProvider.dp.search(nameController.text);
                patients = res;
                if (!mounted) return;
                setState(() {});
            }
        });
        globalVars.downloadNot.addListener(() {
            if (globalVars.downloadNot.value)
                syncIcon = Icons.file_download;
            else
                syncIcon = Icons.sync;
            setState(() {});
        });
        if (globalVars.downloadNot.value) {
            syncIcon = Icons.file_download;
        } else {
            syncIcon = Icons.sync;
        }
        setState(() {});
    }

    Future<void> startService() async {
        if (Platform.isAndroid) {
            try {
                final result = await platform.invokeMethod(
                        'getService', <String, String>{"url": "parameter passed"});
                print(result);
            } on PlatformException catch (e) {
                debugPrint(e.message);
            }
        }
    }

    Future<void> accountSignIn() async {
        // google signin
        // final googleSignIn =
        //     signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
        // final signIn.GoogleSignInAccount account = await googleSignIn.signIn();
        // print("User account $account");
    }

    //   Future<void> uploadFile() async {
    //     final googleSignIn =
    //         signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    //     final signIn.GoogleSignInAccount account = await googleSignIn.signIn();
    //     print("User account $account");
    // // file
    //     final authHeaders = await account.authHeaders;
    //     final authenticateClient = GoogleAuthClient(authHeaders);
    //     final driveApi = drive.DriveApi(authenticateClient);
    //     File toUpload = File(
    //         join((await getApplicationDocumentsDirectory()).path, "register.db"));
    //     Stream<List<int>> mediaStream =
    //         toUpload.openRead().asBroadcastStream();
    //     int len = toUpload.lengthSync();
    //     drive.Media media = new drive.Media(mediaStream, len);
    //     drive.File driveFile = new drive.File();
    //     driveFile.name = "backup.db";
    //     String fileId = prefs.getString("driveFileId");
    //     if(fileId != null && fileId.isNotEmpty)
    //       driveApi.files.delete(fileId);
    //     drive.File result = await driveApi.files.create(driveFile, uploadMedia: media);
    //     print("Upload result: $result");
    //     await prefs.setString("driveFileId", result.id.toString());
    //   }

    bool patientIndexing = true,
    medicineIndexing = true,
    doseIndexing = true,
    dateIndexing = true;

    @override
    Widget build(BuildContext context) {
        double height = MediaQuery.of(context).size.height,
        width = MediaQuery.of(context).size.width;
        return Scaffold(
                backgroundColor: Theme.of(context).backgroundColor,
                appBar: AppBar(
                        elevation: 1,
                        title: Text('Home',
                                style: Theme.of(context)
                                .textTheme
                                .apply(bodyColor: Colors.white)
                                .headline6),
                        actions: <Widget>[
                            IconButton(
                                    icon: Icon(Icons.cloud_upload),
                                    onPressed: () async {
                                        // bool res = await DatabaseProvider.dp.backup();
                                        // if (res) {
                                        //   showToast(msg: 'Backup Successful');
                                        //   // Navigator.pushAndRemoveUntil(
                                        //   //     context, MaterialPageRoute(builder: (context) => Home()),
                                        //   //     (Route r) {
                                        //   //   return r == null;
                                        //   // });
                                        // } else {
                                        //   showToast(msg: 'Backup Failed');
                                        //   // Navigator.pushAndRemoveUntil(
                                        //   //     context, MaterialPageRoute(builder: (context) => Home()),
                                        //   //     (Route r) {
                                        //   //   return r == null;
                                        //   // });
                                        // }
                                        try {
                                            // await uploadFile();
                                            await backUp(context);
                                            showToast(msg: 'Backup Successful');
                                        } catch (e) {
                                            print("Error uploading backup--------------- $e");
                                            showToast(msg: 'Backup Failed');
                                        }
                                    },
                                    ),
                                    IconButton(
                                            icon: Icon(Icons.file_download),
                                            onPressed: () {
                                                confirmAlert(context,
                                                        title: "Import database backup",
                                                        content: "Choose where to import back up from",
                                                        confirm: () async {
                                                            bool res = await DatabaseProvider.dp.import();
                                                            if (res) {
                                                                showToast(msg: 'Database imported');
                                                            } else {
                                                                showToast(msg: 'Import failed');
                                                            }
                                                            Navigator.pop(context);
                                                        }, cancel: () async {
                                                            bool res = await download(context);
                                                            if (res) {
                                                                showToast(msg: 'Database imported');
                                                            } else {
                                                                showToast(msg: 'Import failed');
                                                            }
                                                            Navigator.pop(context);
                                                        }, confirmString: "Local", cancelString: "Cloud");
                                            },
                                            ),
                                            Visibility(
                                                    visible: !kReleaseMode,
                                                    child: IconButton(
                                                            icon: Icon(Icons.delete),
                                                            onPressed: () async {
                                                                await DatabaseProvider.dp.wipe();
                                                                // downloadNot.value = true;
                                                            },
                                                    ),
                                            ),
                                            // IconButton(
                                            //   icon: downloadNot.value
                                            //       ? Icon(syncIcon, color: Colors.white)
                                            //       : Icon(syncIcon, color: Colors.white),
                                            //   onPressed: downloadNot.value
                                            //       ? () async {
                                            //           await DatabaseProvider.dp.synclocal();
                                            //           confirmAlert(context,
                                            //               title: 'Synced Successfully',
                                            //               content: 'Records synced',
                                            //               confirm: () => Navigator.pop(context),
                                            //               cancel: () => Navigator.pop(context));
                                            //         }
                                            //       : () async {
                                            //           await DatabaseProvider.dp.backup();
                                            //           confirmAlert(context,
                                            //               title: 'Backup Successful',
                                            //               content: 'Backup done',
                                            //               confirm: () => Navigator.pop(context),
                                            //               cancel: () => Navigator.pop(context));
                                            //         },
                                            // )
                                            ],
                                            ),
                                            floatingActionButton: FloatingActionButton(
                                                    onPressed: () {
                                                        Navigator.push(
                                                                context, MaterialPageRoute(builder: (context) => NewEntry()));
                                                    },
                                                    elevation: 1,
                                                    child: Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                    ),
                                            ),
                                            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
                                            body: Container(
                                                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                                    width: double.infinity,
                                                    child: Column(
                                                            children: <Widget>[
                                                                Visibility(
                                                                        visible: !kReleaseMode,
                                                                        child: Column(children: [
                                                                            IconButton(
                                                                                    icon: Icon(Icons.file_download),
                                                                                    onPressed: () async {
                                                                                        // await DatabaseProvider.dp.cc();
                                                                                        await startService();
                                                                                    },
                                                                            ),
                                                                            IconButton(
                                                                                    icon: Icon(Icons.cancel),
                                                                                    onPressed: () async {
                                                                                        await DatabaseProvider.dp.dd();
                                                                                    },
                                                                            ),
                                                                            IconButton(
                                                                                    icon: Icon(Icons.search),
                                                                                    onPressed: () async {
                                                                                        await DatabaseProvider.dp.ss();
                                                                                    },
                                                                            ),
                                                                        ]),
                                                                        ),
                                                                        Row(
                                                                                children: <Widget>[
                                                                                    Flexible(
                                                                                            child: Container(
                                                                                                    decoration: BoxDecoration(
                                                                                                            color: Colors.white,
                                                                                                            borderRadius: BorderRadius.only(
                                                                                                                    topLeft: Radius.circular(10),
                                                                                                                    bottomLeft: Radius.circular(10),
                                                                                                            ),
                                                                                                    ),
                                                                                                    child: Row(
                                                                                                            children: <Widget>[
                                                                                                                IconButton(
                                                                                                                        icon: Icon(
                                                                                                                                Icons.search,
                                                                                                                                color: Colors.grey,
                                                                                                                        ),
                                                                                                                        onPressed: () {},
                                                                                                                ),
                                                                                                                Expanded(
                                                                                                                        child: Container(
                                                                                                                                width: width / 2.1,
                                                                                                                                child: TextField(
                                                                                                                                        controller: nameController,
                                                                                                                                        decoration: InputDecoration(
                                                                                                                                                border: InputBorder.none,
                                                                                                                                                hintText: 'Search...',
                                                                                                                                        ),
                                                                                                                                ),
                                                                                                                        ),
                                                                                                                ),
                                                                                                            ],
                                                                                                            ),
                                                                                                            ),
                                                                                                            ),
                                                                                                            SizedBox(
                                                                                                                    width: width / 100,
                                                                                                            ),
                                                                                                            Container(
                                                                                                                    decoration: BoxDecoration(
                                                                                                                            color: Theme.of(context).primaryColor,
                                                                                                                            borderRadius: BorderRadius.only(
                                                                                                                                    topRight: Radius.circular(10),
                                                                                                                                    bottomRight: Radius.circular(10),
                                                                                                                            ),
                                                                                                                    ),
                                                                                                                    child: IconButton(
                                                                                                                            icon: Icon(
                                                                                                                                    Icons.search,
                                                                                                                                    color: Colors.white,
                                                                                                                            ),
                                                                                                                            onPressed: () async {
                                                                                                                                patients.clear();
                                                                                                                                List res =
                                                                                                                                        await DatabaseProvider.dp.search(nameController.text);
                                                                                                                                _hasSearched = true;
                                                                                                                                setState(() {
                                                                                                                                    patients = res;
                                                                                                                                });
                                                                                                                            },
                                                                                                                    ),
                                                                                                                    )
                                                                                                                            ],
                                                                                                                            ),
                                                                                                                            SizedBox(
                                                                                                                                    height: height / 50,
                                                                                                                            ),
                                                                                                                            Container(
                                                                                                                                    padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                                                                                                                                    child: Row(
                                                                                                                                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                                            children: <Widget>[
                                                                                                                                                GestureDetector(
                                                                                                                                                        onTap: () {
                                                                                                                                                            if (patientIndexing)
                                                                                                                                                                patients.sort(
                                                                                                                                                                        (Patient a, Patient b) => a.name.compareTo(b.name));
                                                                                                                                                            else
                                                                                                                                                                patients.sort(
                                                                                                                                                                        (Patient b, Patient a) => a.name.compareTo(b.name));
                                                                                                                                                            patientIndexing = !patientIndexing;
                                                                                                                                                            setState(() {});
                                                                                                                                                        },
                                                                                                                                                        child: Container(
                                                                                                                                                                       padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                                                                                                                                                       width: MediaQuery.of(context).size.width / 4.2,
                                                                                                                                                                       child: Text(
                                                                                                                                                                               'Patient',
                                                                                                                                                                               style: Theme.of(context)
                                                                                                                                                                               .textTheme
                                                                                                                                                                               .apply(fontSizeFactor: 1.1)
                                                                                                                                                                               .bodyText1,
                                                                                                                                                                       ),
                                                                                                                                                               ),
                                                                                                                                                        ),
                                                                                                                                                        GestureDetector(
                                                                                                                                                                onTap: () {
                                                                                                                                                                    if (medicineIndexing)
                                                                                                                                                                        patients.sort((Patient a, Patient b) =>
                                                                                                                                                                                a.lastMedicine.compareTo(b.lastMedicine));
                                                                                                                                                                    else
                                                                                                                                                                        patients.sort((Patient b, Patient a) =>
                                                                                                                                                                                a.lastMedicine.compareTo(b.lastMedicine));
                                                                                                                                                                    medicineIndexing = !medicineIndexing;
                                                                                                                                                                    setState(() {});
                                                                                                                                                                },
                                                                                                                                                                child: Container(
                                                                                                                                                                               width: MediaQuery.of(context).size.width / 4.2,
                                                                                                                                                                               padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                                                                                                                                                               child: Text(
                                                                                                                                                                                       'Medicine',
                                                                                                                                                                                       style: Theme.of(context)
                                                                                                                                                                                       .textTheme
                                                                                                                                                                                       .apply(fontSizeFactor: 1.1)
                                                                                                                                                                                       .bodyText1,
                                                                                                                                                                               ),
                                                                                                                                                                       ),
                                                                                                                                                                ),
                                                                                                                                                                GestureDetector(
                                                                                                                                                                        onTap: () {
                                                                                                                                                                            if (doseIndexing)
                                                                                                                                                                                patients.sort((Patient a, Patient b) =>
                                                                                                                                                                                        a.lastDose.compareTo(b.lastDose));
                                                                                                                                                                            else
                                                                                                                                                                                patients.sort((Patient b, Patient a) =>
                                                                                                                                                                                        a.lastDose.compareTo(b.lastDose));
                                                                                                                                                                            doseIndexing = !doseIndexing;
                                                                                                                                                                            setState(() {});
                                                                                                                                                                        },
                                                                                                                                                                        child: Container(
                                                                                                                                                                                       padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                                                                                                                                                                       width: MediaQuery.of(context).size.width / 5,
                                                                                                                                                                                       child: Text(
                                                                                                                                                                                               'Dosage',
                                                                                                                                                                                               style: Theme.of(context)
                                                                                                                                                                                               .textTheme
                                                                                                                                                                                               .apply(fontSizeFactor: 1.1)
                                                                                                                                                                                               .bodyText1,
                                                                                                                                                                                       ),
                                                                                                                                                                               ),
                                                                                                                                                                        ),
                                                                                                                                                                        GestureDetector(
                                                                                                                                                                                onTap: () {
                                                                                                                                                                                    if (dateIndexing)
                                                                                                                                                                                        patients.sort((Patient a, Patient b) =>
                                                                                                                                                                                                a.lastDate.compareTo(b.lastDate));
                                                                                                                                                                                    else
                                                                                                                                                                                        patients.sort((Patient b, Patient a) =>
                                                                                                                                                                                                a.lastDate.compareTo(b.lastDate));
                                                                                                                                                                                    dateIndexing = !dateIndexing;
                                                                                                                                                                                    setState(() {});
                                                                                                                                                                                },
                                                                                                                                                                                child: Container(
                                                                                                                                                                                               alignment: Alignment.center,
                                                                                                                                                                                               padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                                                                                                                                                                               width: MediaQuery.of(context).size.width / 4.6,
                                                                                                                                                                                               child: Text(
                                                                                                                                                                                                       'Date',
                                                                                                                                                                                                       style: Theme.of(context)
                                                                                                                                                                                                       .textTheme
                                                                                                                                                                                                       .apply(fontSizeFactor: 1.1)
                                                                                                                                                                                                       .bodyText1,
                                                                                                                                                                                               ),
                                                                                                                                                                                       ),
                                                                                                                                                                                ),
                                                                                                                                                                                ],
                                                                                                                                                                                ),
                                                                                                                                                                                ),
                                                                                                                                                                                Expanded(
                                                                                                                                                                                        child: ListView.builder(
                                                                                                                                                                                                itemCount: patients.length,
                                                                                                                                                                                                itemBuilder: (BuildContext context, int i) {
                                                                                                                                                                                                    return patientTile(context, patient: patients[i]);
                                                                                                                                                                                                },
                                                                                                                                                                                        ),
                                                                                                                                                                                )
                                                                                                                                                                                        ],
                                                                                                                                                                                        ),
                                                                                                                                                                                        ),
                                                                                                                                                                                        );
    }

    Future<bool> download(BuildContext context) async {
        User user = globalVars.auth.currentUser;
        if (user == null) {
            globalVars.user = await Navigator.push(
                    context, MaterialPageRoute(builder: (context) => AccountPage()));
            user = globalVars.auth.currentUser;
        }
        // File dbFile = File(
        //     join((await getApplicationDocumentsDirectory()).path, "register.db"));
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text("Import last Backup?"),
        //     action: SnackBarAction(
        //       label: "Yes",
        //       onPressed: () async {
        //         await globalVars.storageRef
        //             .child(globalVars.prefs.getString("lastBackup"))
        //             .writeToFile(dbFile);
        //         ScaffoldMessenger.of(context)
        //           ..removeCurrentSnackBar()
        //           ..showSnackBar(SnackBar(content: Text('File Downloaded')));
        //       },
        //     ),
        //   ),
        // );
        try {
            File dbFile = File(
                    join((await getApplicationDocumentsDirectory()).path, "register.db"));
            String lastBackup;
            if (globalVars.prefs.containsKey("lastBackup")) {
                lastBackup = globalVars.prefs.getString("lastBackup");
                if (lastBackup == null || lastBackup.isEmpty) {
                    showToast(msg: "No Last Backup Found");
                    return false;
                }
            } else {
                ListResult available = await globalVars.storageRef.child("backup/db/${user.uid}").list();
                if(available != null || available.items.length > 0) {
                    final items = available.items;
                    items.first.writeToFile(dbFile);
                    return true;
                }
                showToast(msg: "No Last Backup Found");
                return false;
            }
            await globalVars.storageRef.child(lastBackup).writeToFile(dbFile);
            return true;
        } catch (e) {
            debugPrint("Error occured when downloading file: $e");
            return false;
        }
    }

    Future<void> backUp(BuildContext context) async {
        User user = globalVars.auth.currentUser;
        if (user == null) {
            globalVars.user = await Navigator.push(
                    context, MaterialPageRoute(builder: (context) => AccountPage()));
            user = globalVars.auth.currentUser;
        }
        File dbFile = File(
                join((await getApplicationDocumentsDirectory()).path, "register.db"));
        var uploadRes = await globalVars.storageRef
                .child("backup/db/${user.uid}/${dbFile.uri.pathSegments.last}")
                .putFile(dbFile);
        // String downloadUrl = await uploadRes.ref.getDownloadURL();
        // await globalVars.prefs.setString("lastBackup", downloadUrl);
        await globalVars.prefs.setString(
                "lastBackup", "backup/db/${user.uid}/${dbFile.uri.pathSegments.last}");
        print("File Uploaded: ${uploadRes.ref.name}");
    }
}

Widget patientTile(BuildContext context, {Patient patient}) {
    return GestureDetector(
            onTap: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                                builder: (context) => NewEntry(
                                        patient: patient,
                                )));
            },
            onLongPress: () {
                confirmAlert(context,
                        title: 'Delete Patient',
                        content: 'Are you sure?',
                        confirm: () async {
                            await DatabaseProvider.dp.deletePatient(pid: patient.pid);
                            globalVars.refHome.value = DateTime.now().millisecondsSinceEpoch;
                            Navigator.pop(context);
                        },
                        cancel: () => Navigator.pop(context));
            },
            child: Container(
                           padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                           margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                           width: double.infinity,
                           decoration: BoxDecoration(
                                   color: Colors.white,
                                   borderRadius: BorderRadius.all(Radius.circular(10)),
                                   boxShadow: [
                                       BoxShadow(
                                               color: Colors.grey,
                                               blurRadius: 5,
                                               spreadRadius: 0.5,
                                               offset: Offset(0, 5),
                                       ),
                                   ],
                           ),
                           child: Row(
                                   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: <Widget>[
                                       Container(
                                               width: MediaQuery.of(context).size.width / 4.2,
                                               child: Text(
                                                       patient.name,
                                                       style: Theme.of(context)
                                                       .textTheme
                                                       .apply(fontSizeFactor: 1.2)
                                                       .bodyText1,
                                               ),
                                       ),
                                       Container(
                                               width: MediaQuery.of(context).size.width / 4.2,
                                               child: Text(
                                                       patient.lastMedicine,
                                                       style: Theme.of(context)
                                                       .textTheme
                                                       .apply(fontSizeFactor: 1)
                                                       .bodyText1,
                                               ),
                                       ),
                                       Container(
                                               width: MediaQuery.of(context).size.width / 5,
                                               child: Text(
                                                       patient.lastDose,
                                                       style: Theme.of(context)
                                                       .textTheme
                                                       .apply(fontSizeFactor: 1)
                                                       .bodyText1,
                                               ),
                                       ),
                                       Container(
                                               alignment: Alignment.centerRight,
                                               width: MediaQuery.of(context).size.width / 4.6,
                                               child: Text(
                                                       DateFormat('dd MMM, yyyy')
                                                       .format(DateTime.parse(patient.lastDate)),
                                                       style: Theme.of(context)
                                                       .textTheme
                                                       .apply(fontSizeFactor: 1)
                                                       .bodyText1,
                                               ),
                                       ),
                                       ]),
                                       ),
                                       );
}

Widget medTile(BuildContext context, {Medicine med}) {
    // ignore: unused_local_variable
    double height = MediaQuery.of(context).size.height,
    width = MediaQuery.of(context).size.width;
    return Container(
            decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular((10))),
                    boxShadow: [
                        BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5,
                                spreadRadius: 0.5,
                                offset: Offset(0, 5),
                        ),
                    ],
            ),
            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
            margin: EdgeInsets.fromLTRB(5, 5, 5, 0),
            child: Row(children: <Widget>[
                Container(width: width / 3, child: Text(med.medicine)),
                Container(width: width / 3.6, child: Text(med.dose)),
                Container(
                        alignment: Alignment.center,
                        width: width / 3.6,
                        child: Text(
                                DateFormat('dd MMM, yyyy').format(DateTime.parse(med.date)))),
            ]),
            );
}

class NewEntry extends StatefulWidget {
    final Patient patient;
    NewEntry({this.patient});
    @override
    _NewEntryState createState() => _NewEntryState();
}

class _NewEntryState extends State<NewEntry> {
    final TextEditingController name = new TextEditingController(),
    med = new TextEditingController(),
    dose = new TextEditingController();
    bool _showList = false;
    bool _datePicked = true;
    String _pickedDate = DateTime.now().toIso8601String();
    Future<void> buildPatient() async {
        if (widget.patient == null) {
            return;
        }
        name.text = widget.patient.name;
        widget.patient.setPrevMeds =
                await DatabaseProvider.dp.getMedsForPatient(pid: widget.patient.pid);
        _showList = true;
        setState(() {});
        return;
    }

    @override
    void initState() {
        super.initState();
        buildPatient();
        globalVars.refMeds.addListener(() async {
            print('---------------refMeds called------------');
            if (widget.patient != null) {
                if (widget.patient.pid != null) {
                    widget.patient.setPrevMeds = await DatabaseProvider.dp
                            .getMedsForPatient(pid: widget.patient.pid);

                    if (!mounted) return;
                    setState(() {});
                }
            }
        });
        _datePicked = true;
        _pickedDate = DateTime.now().toIso8601String();
        setState(() {});
    }

    @override
    Widget build(BuildContext context) {
        final double height = MediaQuery.of(context).size.height,
        width = MediaQuery.of(context).size.width;
        return Scaffold(
                backgroundColor: Theme.of(context).backgroundColor,
                appBar: AppBar(
                        title: Text(
                                'New Entry',
                                style: Theme.of(context)
                                .textTheme
                                .apply(bodyColor: Colors.white)
                                .headline6,
                        ),
                ),
                floatingActionButton: FloatingActionButton(
                        onPressed: () async {
                            print('---------new entry----------');
                            String nowName = name.text.trim();
                            String nowMed = med.text.trim();
                            String nowDose = dose.text.trim();
                            // if all medicines are deletd, patient gets deleted in deleteMed func, so create new patient
                            if (widget.patient == null || widget.patient.prevMeds.isEmpty) {
                                if (nowName.isEmpty || nowMed.isEmpty || nowDose.isEmpty) {
                                    showToast(msg: "Fill all fields");
                                    return;
                                } else {
                                    await DatabaseProvider.dp.newPatient(
                                            name: nowName,
                                            medicine: nowMed,
                                            dose: nowDose,
                                            date: _pickedDate);
                                }
                            }
                            // just update name
                            //   only when widget.patient != null
                            //   and nowName not emtpy

                            // for new patient: patient name, dose, med not empty
                            // widget.patient != null, therefore update med
                            else {
                                // old patient
                                if (widget.patient.name != nowName) {
                                    if (nowName.isEmpty) {
                                        showToast(msg: "Please provide patient name");
                                    } else {
                                        await DatabaseProvider.dp
                                                .updateName(pid: widget.patient.pid, name: nowName);
                                    }
                                }
                                if (nowMed.isNotEmpty || nowDose.isNotEmpty) {
                                    if (nowMed.isNotEmpty && nowDose.isNotEmpty) {
                                        await DatabaseProvider.dp.newMed(
                                                dose: nowDose,
                                                medicine: nowMed,
                                                pid: widget.patient.pid,
                                                date: _pickedDate);
                                    } else {
                                        showToast(msg: "Provide both dose and medicine");
                                        return;
                                    }
                                }
                            }
                            globalVars.refHome.value = DateTime.now().millisecondsSinceEpoch;
                            globalVars.downloadNot.value = false;
                            Navigator.pop(context);
                        },
                child: Icon(Icons.done, color: Colors.white),
                elevation: 1,
                ),
                body: Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                    formFields(
                                            context,
                                            label: 'Name',
                                            hint: 'Patient Name',
                                            controller: name,
                                    ), //isenabled: widget.patient == null),
                        formFields(context,
                                label: 'Medicine Prescribed',
                                hint: 'Medicine name',
                                controller: med),
                        formFields(context,
                                label: 'Interval between doses',
                                hint: 'Prescribed dosage',
                                controller: dose),
                        // Row(
                        //   children: <Widget>[
                            //     Container(
                            //       padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                            //       child: RaisedButton(
                            //         child: Text('Pick Date'),
                            //         onPressed: () {
                            //           setState(() {
                            //             _datePicked = !_datePicked;
                            //           });
                            //         },
                            //       ),
                            //     ),
                            //     SizedBox(width: 10),
                            //     Expanded(
                            //       child: formFields(
                            //         context,
                            //         label: "Date Prescribed",
                            //         isenabled: false,
                            //         text: _pickedDate.isNotEmpty ? DateFormat('dd MMM, yyyy').format(DateTime.parse(_pickedDate)) : '',
                            //       ),
                            //     ),
                            //   ],
                            // ),
                        GestureDetector(
                                onTap: () {
                                    setState(() {
                                        _datePicked = !_datePicked;
                                    });
                                },
                                child: formFields(
                                               context,
                                               label: "Date Prescribed",
                                               isenabled: false,
                                               text: DateFormat('dd MMM, yyyy')
                                               .format(DateTime.parse(_pickedDate)),
                                       ),
                        ),
                        Visibility(
                                visible: !_datePicked,
                                child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.height / 3,
                                        child: CalendarDatePicker(
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                                                lastDate: DateTime.now(),
                                                onDateChanged: (DateTime picked) {
                                                    _datePicked = true;
                                                    _pickedDate = picked.toIso8601String();
                                                    setState(() {});
                                                }),
                                ),
                        ),
                        Visibility(
                                visible: _showList,
                                child: Container(
                                        padding: EdgeInsets.fromLTRB(10, 20, 0, 5),
                                        child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                    Text(
                                                            'Medicines Prescribed previously',
                                                            style: Theme.of(context)
                                                            .textTheme
                                                            .apply(fontSizeFactor: 1.1)
                                                            .bodyText1,
                                                    ),
                                                    SizedBox(
                                                            height: height / 100,
                                                    ),
                                                    Row(children: <Widget>[
                                                        Container(
                                                                width: width / 3,
                                                                child: Text(
                                                                        'Medicine',
                                                                        style: Theme.of(context)
                                                                        .textTheme
                                                                        .apply(fontSizeFactor: 1)
                                                                        .bodyText2,
                                                                )),
                                                        Container(
                                                                width: width / 3.6,
                                                                child: Text(
                                                                        'Dose',
                                                                        style: Theme.of(context)
                                                                        .textTheme
                                                                        .apply(fontSizeFactor: 1)
                                                                        .bodyText2,
                                                                )),
                                                        Container(
                                                                alignment: Alignment.center,
                                                                width: width / 3.6,
                                                                child: Text('Date')),
                                                        ]),
                                                        ],
                                                        ),
                                                        ),
                                                        ),
                                                        Expanded(
                                                                child: ListView.builder(
                                                                        itemCount: _showList ? widget.patient.prevMeds.length : 0,
                                                                        itemBuilder: (BuildContext context, int i) {
                                                                            return GestureDetector(
                                                                                    onLongPress: () {
                                                                                        confirmAlert(context,
                                                                                                title: 'Delete Prescription',
                                                                                                content: 'Are you sure?',
                                                                                                confirm: () async {
                                                                                                    await DatabaseProvider.dp
                                                                                                            .deleteMed(widget.patient.prevMeds[i]);
                                                                                                    Navigator.pop(context);
                                                                                                },
                                                                                                cancel: () => Navigator.pop(context));
                                                                                    },
                                                                                    child: medTile(context,
                                                                                                   med: widget.patient.prevMeds[i]));
                                                                        }))
                                                        ],
                                                        ),
                                                        ),
                                                        );
    }
}

Widget formFields(BuildContext context,
        {String label = '',
            TextEditingController controller,
            String hint = '',
            String text = '',
            bool isenabled = true}) {
    double height = MediaQuery.of(context).size.height,
    // ignore: unused_local_variable
    width = MediaQuery.of(context).size.width;
    if (controller == null) {
        controller = TextEditingController();
        controller.text = text;
    }
    return Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        Text(
                                label,
                                style: Theme.of(context)
                                .textTheme
                                .apply(bodyColor: Colors.black.withOpacity(0.7))
                                .bodyText2,
                        ),
                        SizedBox(
                                height: height / 100,
                        ),
                        Container(
                                padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                child: TextField(
                                        enabled: isenabled,
                                        controller: controller,
                                        decoration:
                                        InputDecoration(hintText: hint, border: InputBorder.none),
                                ),
                        )
                                ],
                                ),
                                );
}

void showToast({@required String msg}) {
    Fluttertoast.showToast(
            msg: msg,
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_LONG,
            fontSize: 13,
            backgroundColor: Colors.black.withOpacity(0.7),
            textColor: Colors.white);
}

void confirmAlert(BuildContext context,
        {String title = '',
            String content = '',
            String cancelString = 'Cancel',
            String confirmString = 'Confirm',
            Function cancel,
            Function confirm}) {
    showDialog(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                        title: Text(title),
                        content: Text(content),
                        actions: <Widget>[
                            ElevatedButton(
                                    child: Text(cancelString),
                                    onPressed: cancel,
                            ),
                            ElevatedButton(
                                    child: Text(confirmString),
                                    onPressed: confirm,
                            ),
                        ],
                );
            });
}

// Widget selectDate(BuildContext context) {
//     return Column(
//       children: <Widget>[
    //         Container(
    //           padding: EdgeInsets.only(left: 8.0),
    //           height: MediaQuery.of(context).size.height / 15,
    //           decoration: BoxDecoration(
    //             color: Colors.white,
    //             borderRadius: BorderRadius.all(
    //               Radius.circular(15 / 1920 * MediaQuery.of(context).size.height),
    //             ),
    //           ),
    //           child: DateTimeField(
    //             decoration: InputDecoration(
    //               border: InputBorder.none,
    //               contentPadding: EdgeInsets.symmetric(vertical: 20),
    //               // icon: Icon(Icons.calendar_today),
    //             ),
    //             format: DateFormat("yyyy-MM-dd HH:mm:ss"),
    //             // format: DateFormat("dd, MMM yyyy hh:mm a"),
    //             onShowPicker: (context, currentValue) async {
    //               DateTime date = (await showDatePicker(
    //                 context: context,
    //                 firstDate: DateTime(1900),
    //                 initialDate: currentValue ?? DateTime.now(),
    //                 lastDate: DateTime.now(),
    //               )); // .toString();
    //               // if(date == null) {
    //               // date = DateFormat('yyyy-MM-dd').parse(DateTime.now().toString());// DateFormat('yyyy-mm-dd').format(DateTime.now());
    //               // }
    //               if (date != null) {
    //                 TimeOfDay time = (await showTimePicker(
    //                     context: context,
    //                     initialTime: TimeOfDay.fromDateTime(
    //                         currentValue ?? DateTime.now()))); //.toString();
    //                 return DateTimeField.combine(date, time);
    //               } else {
    //                 return currentValue;
    //               }
    //               // if(time == null) {
    //               //   time = DateFormat('HH:mm:ss').format(DateTime.now());
    //               // }
    //               // dateTimeText = '$date $time';
    //               // setState(() {});
    //               // return DateTimeField.combine(DateTime.parse(date), TimeOfDay.fromDateTime(DateTime.parse(time)));
    //               // return DateTimeField.combine(date, time);
    //             },
    //             controller: dateCtrl,
    //             readOnly: true,
    //             onChanged: (DateTime dt) {
    //               // print(dt);
    //               if (dt != null) {
    //                 dateTimeText = DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
    //                 // print(dateTimeText);
    //               }
    //               setState(() {});
    //             },
    //           ),
    //         ),
    //       ],
    //     );
    //   }

class AccountPage extends StatefulWidget {
    const AccountPage({Key key}) : super(key: key);

    @override
    _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String _email, _password;
    @override
    Widget build(BuildContext context) {
        return Scaffold(
                appBar: AppBar(
                        title: Text("Sign In"),
                ),
                body: Form(
                        key: _formKey,
                        child: Column(
                                children: <Widget>[
                                    TextFormField(
                                            // ignore: missing_return
                                            validator: (String val) {
                                                if (val.isEmpty) {
                                                    return "Please provide email";
                                                }
                                                // return "";
                                            },
                                            onSaved: (val) => _email = val.trim(),
                                            decoration: InputDecoration(
                                                    labelText: "Email",
                                            ),
                                    ),
                                    TextFormField(
                                            // ignore: missing_return
                                            validator: (String val) {
                                                if (val.isEmpty) {
                                                    return "Please provide password";
                                                }
                                                // return "";
                                            },
                                            onSaved: (val) => _password = val.trim(),
                                            decoration: InputDecoration(labelText: "Password"),
                                            obscureText: true,
                                    ),
                                    Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                                ElevatedButton(
                                                        onPressed: () => signUp(context),
                                                        child: Text("Register"),
                                                ),
                                                ElevatedButton(
                                                        onPressed: () => signIn(context),
                                                        child: Text("Sign In"),
                                                ),
                                                // ElevatedButton(
                                                //   onPressed: () => startService(
                                                //       email: "sam@example.com",
                                                //       password: "sam123",
                                                //       method: accountMethods[Account.SignIn.index]),
                                                //   child: Text("Method Channel"),
                                                // ),
                                            ],
                                    ),
                                    ],
                                    ),
                                    ),
                                    );
    }

    Future<void> signUp(BuildContext context) async {
        final formState = _formKey.currentState;
        if (formState.validate()) {
            formState.save();
            try {
                await globalVars.auth
                        .createUserWithEmailAndPassword(email: _email, password: _password);
                ScaffoldMessenger.of(context)
                        .showSnackBar(new SnackBar(content: Text("Please Log in")));
            } catch (e) {
                String code = e.code;
                if (code == "email-already-in-use") {
                    ScaffoldMessenger.of(context)
                            .showSnackBar(new SnackBar(content: Text("Please Log in")));
                } else if (code == "invalid-email") {
                    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                                    content: Text("Please provide a valid email address")));
                } else if (code == "weak-password") {
                    ScaffoldMessenger.of(context)
                            .showSnackBar(new SnackBar(content: Text("Please provide a stronger password")));
                }

                debugPrint("########### Register User failed with: ${e.code}");
            }
        }
    }

    Future<void> signIn(BuildContext context) async {
        final formState = _formKey.currentState;
        if (formState.validate()) {
            formState.save();
            try {
                UserCredential userCredential = await globalVars.auth
                        .signInWithEmailAndPassword(email: _email, password: _password);
                User user = userCredential.user;
                print(user.displayName);
                ScaffoldMessenger.of(context).showSnackBar(
                        new SnackBar(content: Text("Successfully logged in")));
                Navigator.pop(context, userCredential.user);
            } catch (e) {
                String code = e.code;
                if (code == "user-not-found") {
                    ScaffoldMessenger.of(context)
                            .showSnackBar(new SnackBar(content: Text("No User found. Please register before logging in.")));
                } else if (code == "invalid-email") {
                    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                                    content: Text("Please provide a valid email address")));
                } else if (code == "wrong-password") {
                    ScaffoldMessenger.of(context)
                            .showSnackBar(new SnackBar(content: Text("Email and password do not match. Please check.")));
                }
                debugPrint("########### Sign In User failed with: ${e.code}");
            }
        }
    }
}
