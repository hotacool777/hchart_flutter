import 'dart:ui';

import '../Data/HFChartDataEntry.dart';
import '../Model/HFChartModel.dart';
import '../Model/HFGraphicFoundation.dart';
import '../Providers/HFFocusProvider.dart';
import '../Renderer/HFFocusRenderer.dart';
import 'HFChartNode.dart';

class HFFocusNode extends HFChartNode implements HFFocusProvider {
  HFPoint focusPoint = HFPoint.INVALID_POINT;
  HFChartDataEntry? itemData;
  late HFFocusRenderer focusRenderer;

  HFFocusNode(Canvas canvas) : super(canvas);

  @override
  List focusDataInRect(HFRect rect) {
//print('focusDataInRect: ' + this.focusPoint.toString());
//print('focusDataInRect itemData: ' + this.itemData.toString());
    if (focusPoint.isValid()) {
      HFFocusModel focusModel = HFFocusModel();
      focusModel.point = focusPoint;

      if (itemData is HFKLineEntry) {
        // K 线
        HFKLineEntry klineData = itemData as HFKLineEntry;
        focusModel.appendText = [klineData.close.toString()];
        focusModel.alertText = [
          klineData.date.toString(),
          klineData.high.toString(),
          klineData.low.toString(),
          klineData.open.toString(),
          klineData.close.toString()
        ]; // alert 框信息
        focusModel.text = klineData.close.toString(); // x轴坐标值
        focusModel.extText = klineData.date.toString(); // y 轴坐标值
      } else {
        focusModel.appendText = ['aaaa', 'bbbb'];
        focusModel.alertText = ['aaaa', 'bbbb'];
      }
      return [focusModel];
    }
    return [];
  }

  @override
  void initialDefaultSetting() {
    focusRenderer = HFFocusRenderer(this);
    super.initialDefaultSetting();
  }

  @override
  void setNeedsDisplay() {
    super.setNeedsDisplay();
    focusRenderer.draw(pointRect, canvas);
  }
}
