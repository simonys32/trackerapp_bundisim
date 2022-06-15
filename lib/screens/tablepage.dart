import 'package:flutter/material.dart';
import 'package:trackerapp_bundisim/constants/globalvariables.dart';

class TablePage extends StatefulWidget {
  const TablePage({Key? key}) : super(key: key);

  @override
  _TablePageState createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  bool loaded = false;
  int selectedMonth = DateTime.now().month;
  List dropDownItem = [
    ['All', 13],
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

  //Auswahldropdown und Tabelle
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: GlobalVariables.backgroundColor,
        body: Center(
          child: Column(
            children: [
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
                    });
                  }),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  border: TableBorder.all(
                      width: 0.1, borderRadius: BorderRadius.circular(10)),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  // columnWidths: const <int, TableColumnWidth>{
                  //   0: FixedColumnWidth(150),
                  //   1: FlexColumnWidth(),
                  // },
                  children:
                      GlobalVariables.loadTableItems(context, selectedMonth),
                ),
              ),
              GlobalVariables.tableItems.length == 1
                  ? Expanded(
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
                  : SizedBox()
            ],
          ),
        ));
  }
}
