import 'dart:ui';

import 'HFChartDataEntry.dart';

const String HF_QUOTE_BASIC_LABEL = "BASIC";
const String HF_QUOTE_TIMELINE_LABEL = "TIMELINE";
const String HF_QUOTE_KLINE_LABEL = "KLINE";

class HFChartDataSet {
  List<HFChartDataEntry> values;
  String label;

  HFChartDataSet(this.values, this.label);
}

class HFLineChartDataSet extends HFChartDataSet {
  double lineWidth = 1;
  Color lineColor = const Color(0xFFFD5E53);
  Color fillColor = const Color(0xFFFD5E53);
  bool isCubic = true;
  bool isGradient = false;

  HFLineChartDataSet(List<HFChartDataEntry> values, String label)
      : super(values, label);
}
