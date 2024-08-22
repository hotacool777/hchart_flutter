import 'dart:ui';

import '../Data/HFChartData.dart';
import '../Data/HFChartDataEntry.dart';
import '../Model/HFChartModel.dart';
import '../Model/HFGraphicFoundation.dart';
import '../Providers/HFProvider.dart';

class HFChartNode implements HFProvider {
  // UI属性
  num lineWidth = 0.5;
  Color lineColor = const Color(0xFFFD5E53);
  Color fillColor = const Color(0xFFFD5E53);
  bool isCubic = false;
  bool isGradient = false;
  bool isCenter = true;
  num stepWidth = 0;
  num spacing = 1;
  int focusIndex = -1;

  @override
  int actualCnt = 0;

  @override
  int endIndex = 0;

  @override
  HFRect pointRect = HFRect.ZERO_RECT;

  @override
  int startIndex = 0;

  @override
  int visualCnt = 0;

  @override
  int xAxisCnt = 0;

  @override
  int yAxisCnt = 0;

  num maxValue = HF_INTEGER_MAX_VALUE;
  num minValue = HF_INTEGER_MIN_VALUE;

  Canvas canvas;
  HFChartData? _data;

  HFChartData? get data => _data;

  set data(HFChartData? value) {
//print('data: $value');
    _data = value;
    if (_data == null) {
      // TODO: clear canvas
      return;
    }
    calculateLimitValue();
  }

  HFChartNode(this.canvas) {
    initialDefaultSetting();
  }

  void initialDefaultSetting() {
//print('initialDefaultSetting');
  }

  void setNeedsDisplay() {
//print('setNeedsDisplay');
  }

  @override
  void calculateLimitValue() {
    // TODO: implement calculateLimitValue
    var max = HF_INTEGER_MIN_VALUE;
    var min = HF_INTEGER_MAX_VALUE;
    maxValue = max == HF_INTEGER_MIN_VALUE ? 0 : max;
    minValue = min == HF_INTEGER_MAX_VALUE ? 0 : min;
  }

  @override
  num calculatorX(num forValue, num min, num max, HFRect inRect) {
    // TODO: implement calculatorX
    throw UnimplementedError();
  }

  @override
  num calculatorY(num forValue, num min, num max, HFRect inRect) {
    // TODO: implement calculatorY
    throw UnimplementedError();
  }

  Color colorWithValueType(HFValueUpDownType type) {
    var color = const Color(0xFF000000);
    switch (type) {
      case HFValueUpDownType.up:
        color = const Color(0xFFEB4545);
        break;
      case HFValueUpDownType.down:
        color = const Color(0xFF4CA865);
        break;
      case HFValueUpDownType.equal:
        color = const Color(0xFF87999F);
        break;
      default:
        break;
    }
    return color;
  }

  num relativeIdxFromIndex(num i) {
    var idx = i - startIndex;
    var showCnt = endIndex - startIndex + 1;
    if (startIndex == 0 && showCnt < visualCnt) {
      //滑到最左端，已无历史数据时，显示最前端数据
      idx = visualCnt - showCnt + i;
    }
    return idx;
  }

  num xPoint(num index, HFRect inRect) {
    var x = index * stepWidth + inRect.minX();
    return x;
  }

  @override
  double contentWidth() {
    return pointRect.width.toDouble();
  }

  void updateStepWidth() {
    if (isCenter) {
      if (visualCnt > 0) {
        stepWidth =
            double.parse((pointRect.width / visualCnt).toStringAsFixed(3));
      }
    } else {
      if (visualCnt > 1) {
        stepWidth = double.parse(
            (pointRect.width / (visualCnt - 1)).toStringAsFixed(3));
      }
    }
  }

  // 获取point对应的index
  int indexAtChartForPoint(HFPoint point) {
    return 0;
  }

  // 获取index对应的point
  HFPoint pointAtChartForIndex(int index) {
    return HFPoint.INVALID_POINT;
  }

  // 获取坐标点对应的数据
  HFChartDataEntry? dataAtChartForPoint(HFPoint point) {
    return null;
  }

  // 获取index对应的数据
  HFChartDataEntry? dataAtChartForIndex(int index) {
    return null;
  }
}
