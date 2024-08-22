import 'HFChartDataSet.dart';

class HFChartData {
  List<HFChartDataSet> dataSets;

  HFChartData(this.dataSets);

  HFChartData appendData(HFChartData data) {
    // TODO: append data
    return this;
  }

  HFChartDataSet? getDataSetWithLabel(String label) {
    if (dataSets.isNotEmpty) {
      for (var value in dataSets) {
        if (value.label == label) {
          return value;
        }
      }
    }
    return null;
  }
}
