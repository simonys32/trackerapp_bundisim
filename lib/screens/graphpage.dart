import 'dart:async';
import 'dart:convert';
import "package:collection/collection.dart";
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trackerapp_bundisim/constants/globalvariables.dart';
import '../services/graph.dart';
import '../models/measurement.dart';
import '../services/nativeCode.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({Key? key}) : super(key: key);

  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> with WidgetsBindingObserver {
  static const platform = MethodChannel("com.tracker.bundisim/data");

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

  List dropDownItem = [
    ['Jan', 01],
    ['Feb', 02],
    ['Mar', 03],
    ['April', 04],
    ['May', 05],
    ['Jun', 06],
    ['Jul', 07],
    ['Aug', 08],
    ['Sep', 09],
    ['Oct', 10],
    ['Nov', 11],
    ['Dec', 12],
  ];

//Erneuert und fragt die Daten Zeitbasiert ab
  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    platform.invokeMethod('getHealthInfo').then((value) {
      print(value);
      if (value) {
        permissionGranted = true;
        getHealthData();
        Timer.periodic(Duration(hours: 1), (timer) {
          getHealthData();
        });
      } else {
        permissionGranted = false;

        print('Permission not granted');
      }
    });
    super.initState();
  }

//Erneuert die Daten bei Neuöffnung
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getHealthData();
    }
  }

//Erneuert und zeigt Daten an
  getHealthData() {
    print("pressed");
    List<Measurement> allHealthData = [];
    NativeCode.streamData().listen((event) {
      print(event ?? '');
      Map receivedData = jsonDecode(event);
      GlobalVariables.healthData = receivedData;
      healthData.clear();
      allHealthData.clear();
      receivedData.forEach((key, value) {
        List date = key.toString().split(',')[1].trim().split('-');
        allHealthData.add(Measurement(
            int.parse(date[1]), double.parse(value) * 100, int.parse(date[0])));
      });
      allHealthData.forEach((element1) {
        healthData.add(
            Measurement(element1.day, element1.percentage, element1.month));
        List<Measurement> temp = healthData
            .where((element) =>
                element.month == element1.month && element.day == element1.day)
            .toList();
        healthData.removeWhere((element) =>
            element.month == element1.month && element.day == element1.day);
        healthData.add(Measurement(element1.day,
            temp.map((m) => m.percentage).average, element1.month));
      });

      setState(() {
        selectedHealthData = healthData
            .where((element) => element.month == DateTime.now().month)
            .toList();
        selectedHealthData.sort((a, b) => Comparable.compare(a.day, b.day));
        loaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: GlobalVariables.backgroundColor,
        body: Center(
          child: Column(children: [
            DropdownButton(
                value: selectedMonth,
                items: dropDownItem
                    .map((e) => DropdownMenuItem(
                          value: e[1],
                          child: Text(e[0]),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedMonth = val as int;
                    selectedHealthData = healthData
                        .where((element) => element.month == selectedMonth)
                        .toList();
                    selectedHealthData
                        .sort((a, b) => Comparable.compare(a.day, b.day));
                  });
                }),
            loaded
                ? selectedHealthData.length != 0
                    ? Expanded(
                        child: NumericComboLinePointChart(selectedHealthData),
                      )
                    : Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Icon(Icons.info),
                            SizedBox(
                              height: 10,
                            ),
                            Container(child: Text('No Data for this month'))
                          ],
                        ),
                      )
                : CupertinoActivityIndicator()
          ]),
        ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }
}
