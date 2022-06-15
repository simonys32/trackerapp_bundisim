import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/measurement.dart';

class GlobalVariables {
  //Globale Variablen definieren
  static late Map healthData;
  static List<TableRow> tableItems = [];
  static Color navColor = Color(0xff242F9B);
  static Color backgroundColor = Color(0xff9BA3EB);

  //Tabellendaten laden
  static List<TableRow> loadTableItems(context, month) {
    tableItems.clear();
    List healthData1 = month != 13
        ? healthData.keys
            .where((element) =>
                int.parse(element.split(',')[1].split('-')[0]) == month)
            .toList()
        : healthData.keys.toList();
    List keys = healthData1;
    print(keys);
    tableItems.add(TableRow(
      children: [
        TableCell(
          child: Container(
            color: Colors.blueAccent,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.008,
                bottom: MediaQuery.of(context).size.height * 0.008,
              ),
              child: Text(
                "Index",
                style: GoogleFonts.roboto(
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        TableCell(
          child: Container(
            color: Colors.blueAccent,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.008,
                bottom: MediaQuery.of(context).size.height * 0.008,
              ),
              child: Text(
                "Time",
                style: GoogleFonts.roboto(
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        TableCell(
          child: Container(
            color: Colors.blueAccent,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.008,
                bottom: MediaQuery.of(context).size.height * 0.008,
              ),
              child: Text(
                "Date",
                style: GoogleFonts.roboto(
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        TableCell(
          child: Container(
            color: Colors.blueAccent,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.008,
                bottom: MediaQuery.of(context).size.height * 0.008,
              ),
              child: Text(
                "Percentage",
                style: GoogleFonts.roboto(
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    ));
    keys.sort((a, b) {
      DateTime aDate = DateTime(
          int.parse(a.split(',')[1].split('-')[2]),
          int.parse(a.split(',')[1].split('-')[0]),
          int.parse(a.split(',')[1].split('-')[1]));
      DateTime bDate = DateTime(
          int.parse(b.split(',')[1].split('-')[2]),
          int.parse(b.split(',')[1].split('-')[0]),
          int.parse(b.split(',')[1].split('-')[1]));
      return Comparable.compare(aDate, bDate);
    });
    for (int i = 0; i < keys.length; i++) {
      tableItems.add(TableRow(children: [
        TableCell(
          child: Container(
            color: Color(0xffF4F2E5),
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.008,
                bottom: MediaQuery.of(context).size.height * 0.008,
              ),
              child: Text(
                (i + 1).toString(),
                style: GoogleFonts.roboto(
                    fontSize: MediaQuery.of(context).size.width * 0.035,
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        TableCell(
          child: Container(
            color: Color(0xffF4F2E5),
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.008,
                bottom: MediaQuery.of(context).size.height * 0.008,
              ),
              child: Text(
                keys[i].split(',')[0],
                style: GoogleFonts.roboto(
                    fontSize: MediaQuery.of(context).size.width * 0.035,
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        TableCell(
          child: Container(
            color: Color(0xffF4F2E5),
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.008,
                bottom: MediaQuery.of(context).size.height * 0.008,
              ),
              child: Text(
                keys[i].split(',')[1],
                style: GoogleFonts.roboto(
                    fontSize: MediaQuery.of(context).size.width * 0.035,
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        TableCell(
          child: Container(
            color: Color(0xffF4F2E5),
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.008,
                bottom: MediaQuery.of(context).size.height * 0.008,
              ),
              child: Text(
                (double.parse(healthData[keys[i]]) * 100).toString(),
                style: GoogleFonts.roboto(
                    fontSize: MediaQuery.of(context).size.width * 0.035,
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ]));
    }

    return tableItems;
  }
}
