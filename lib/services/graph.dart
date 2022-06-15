// FOR GRAPH

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:quiver/time.dart';

import '../models/measurement.dart';

class NumericComboLinePointChart extends StatelessWidget {
  List<Measurement> healthData;

  NumericComboLinePointChart(this.healthData);

//erstellt  Diagramm mit flutter chart package
  @override
  Widget build(BuildContext context) {
    return charts.NumericComboChart(_createSampleData(healthData),
        animate: true,
        defaultRenderer: charts.LineRendererConfig(),
        primaryMeasureAxis: const charts.NumericAxisSpec(
            renderSpec: charts.GridlineRendererSpec(
                labelStyle: charts.TextStyleSpec(
                    fontSize: 10, color: charts.MaterialPalette.white),
                lineStyle: charts.LineStyleSpec(
                    thickness: 0, color: charts.MaterialPalette.white))),
        domainAxis: const charts.NumericAxisSpec(
            viewport: charts.NumericExtents(1.0, 31.0),
            renderSpec: charts.GridlineRendererSpec(
                labelStyle: charts.TextStyleSpec(
                    fontSize: 10, color: charts.MaterialPalette.white),
                lineStyle: charts.LineStyleSpec(
                    thickness: 0, color: charts.MaterialPalette.white))),
        customSeriesRenderers: [
          charts.PointRendererConfig(customRendererId: 'customPoint')
        ]);
  }

  /// Series wird erstellt mit HealthDaten.
  static List<charts.Series<Measurement, int>> _createSampleData(healthData) {
    return [
      charts.Series<Measurement, int>(
        id: 'Desktop',
        colorFn: (_, __) => charts.MaterialPalette.white,
        domainFn: (Measurement data, _) => data.day,
        measureFn: (Measurement data, _) => data.percentage,
        domainLowerBoundFn: (Measurement data, _) => 1,
        domainUpperBoundFn: (Measurement data, _) =>
            daysInMonth(DateTime.now().year, data.month),
        measureUpperBoundFn: (Measurement data, _) => 100,
        measureLowerBoundFn: (Measurement data, _) => 0,
        data: healthData,
      ),
      charts.Series<Measurement, int>(
          id: 'Mobile',
          colorFn: (_, __) => charts.MaterialPalette.white,
          domainFn: (Measurement data, _) => data.day,
          measureFn: (Measurement data, _) => data.percentage,
          data: healthData)
        ..setAttribute(charts.rendererIdKey, 'customPoint'),
    ];
  }
}
