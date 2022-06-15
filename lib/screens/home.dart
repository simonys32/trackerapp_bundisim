// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trackerapp_bundisim/constants/globalvariables.dart';
import 'package:trackerapp_bundisim/screens/tablepage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trackerapp_bundisim/screens/graphpage.dart';
import '../models/measurement.dart';
import './graphpage.dart';
import '../services/nativeCode.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  static const platform = MethodChannel("com.flutter.epic/epic");
  //Setzt aktuellen Monaat als Startwert im dropdown
  int selectedMonth = DateTime.now().month;
  //Variablen um zu überprüfen, ob alle Prozesse durchgelaufen sind, bevor Elemente angezeigt werden
  bool loaded = false;
  bool permissionGranted = false;

  //Datenavariabeln für das Diagramm
  List<Measurement> healthData = [];
  List<Measurement> selectedHealthData = [];

  //Index der aktuellen seite in der navigation 0 = graph page
  int pageIndex = 0;

//Wandelt Daten von Objekten in json um und gibt das Resultat aus
  getHealthJson() {
    print("pressed");
    List<Measurement> allHealthData = [];
    NativeCode.streamData().listen((event) async {
      print(event ?? '');
      if (event != null) {
        final Directory directory = await getApplicationDocumentsDirectory();
        final File file = File('${directory.path}/data_export1.json');
        await file.writeAsString(event);
        Map<String, dynamic> myJson =
            await json.decode(await file.readAsString());
        print('Exported json: ' + myJson.toString());
        Share.shareFiles([file.path]);
      }
    });
  }

//Wandelt Daten von Objekten in csv um und gibt das Resultat aus
  getHealthCsv() {
    List<List<dynamic>> rows = [];
    List<dynamic> row = [];
    List<Measurement> allHealthData = [];
    NativeCode.streamData().listen((event) async {
      print(event ?? '');
      if (event != null) {
        Map data = jsonDecode(event) as Map;
        List keys = data.keys.toList();
        row.add('index');
        row.add('time');
        row.add('date');
        row.add('percentage');
        rows.add(row);
        for (int i = 0; i < keys.length; i++) {
          List<dynamic> row = [];
          row.add(i + 1);
          row.add(keys[i].split(',')[0]);
          row.add(keys[i].split(',')[1]);
          row.add(data[keys[i]]);
          rows.add(row);
        }
        String csv =
            const ListToCsvConverter().convert(rows, fieldDelimiter: ',');
        print(csv);

        final Directory directory = await getApplicationDocumentsDirectory();
        final File file = File('${directory.path}/data_export2.csv');
        await file.writeAsString(csv);
        Share.shareFiles([file.path]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: GlobalVariables.navColor,
          title: const Text('Home'),
          centerTitle: true,
        ),
        backgroundColor: GlobalVariables.backgroundColor,
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: GlobalVariables.navColor,
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: pageIndex,
          items: [
            BottomNavigationBarItem(
                icon: const Icon(Icons.show_chart), label: 'Chart'),
            BottomNavigationBarItem(
                icon: const Icon(Icons.insert_chart), label: 'Table'),
          ],
          onTap: (index) {
            setState(() {
              pageIndex = index;
            });
          },
        ),
        drawer: SafeArea(
          child: Drawer(
            backgroundColor: GlobalVariables.navColor,
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Center(
                      child: Text('Tracker App for asymmetrical Walking')),
                ),
                TextButton(
                  child: const Text('Export as JSON',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    Navigator.pop(context);
                    getHealthJson();
                  },
                ),
                Divider(
                  thickness: 1,
                ),
                TextButton(
                  child: const Text('Export as CSV',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    Navigator.pop(context);
                    getHealthCsv();
                  },
                ),
                Divider(
                  thickness: 1,
                ),
                TextButton(
                  child: const Text('Show Information',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    Navigator.pop(context);
                    showAlertDialog(context);
                  },
                ),
                Divider(
                  thickness: 1,
                ),
              ],
            ),
          ),
        ),
        body: pageIndex == 0 ? const GraphPage() : const TablePage());
  }

  //Disclaimer
  showAlertDialog(BuildContext context) {
    // Button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    //  AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Information"),
      content: Text('''
This app is used to track the asymmetrical percentage in ones walking behaviour \n Version 1.0'''),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }
}
