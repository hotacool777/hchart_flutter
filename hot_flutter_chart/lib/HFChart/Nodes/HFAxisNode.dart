import 'dart:math';
import 'dart:ui';

import '../Data/HFChartData.dart';
import '../Model/HFChartModel.dart';
import '../Model/HFGraphicFoundation.dart';
import '../Providers/HFAxisProvider.dart';
import '../Renderer/HFAxisRenderer.dart';
import 'HFChartNode.dart';

class HFAxisNode extends HFChartNode implements HFAxisProvider {
  late HFAxisRenderer xAxisRenderer;
  late HFAxisRenderer yAxisRenderer;

  HFAxisNode(Canvas canvas) : super(canvas);

  @override
  set data(HFChartData? value) {
    super.data = value;
    calculateLimitValue();
  }

  @override
  void initialDefaultSetting() {
    xAxisCnt = 5;
    yAxisCnt = 5;

    xAxisRenderer = HFAxisRenderer(this);
    xAxisRenderer.axisType = HFAxisType.x;
    yAxisRenderer = HFAxisRenderer(this);
    yAxisRenderer.axisType = HFAxisType.y;
    super.initialDefaultSetting();
  }

  @override
  void setNeedsDisplay() {
    super.setNeedsDisplay();
    xAxisRenderer.draw(pointRect, canvas);
    yAxisRenderer.draw(pointRect, canvas);
  }

  @override
  List axisDataInRect(HFRect rect) {
    // TODO: implement axisDataInRect
    throw UnimplementedError();
  }

  @override
  List xAxisDataInRect(HFRect rect) {
    num axisCnt = xAxisCnt;
    if (axisCnt <= 1) {
      return [];
    }
    var axisDrawingComps = <HFAxisModel>[];
    for (var index = 0; index < axisCnt; index++) {
      var axisItem = HFAxisModel();
      axisItem.index = index;
      axisItem.axisType = HFAxisType.x;
      axisItem.location = getAxisLocation(index, axisCnt);
      var y = calculatorY(index, 0, axisCnt - 1, pointRect);

      // axisItem.text = this.getTextForAxisItem(axisItem)
      var yValue =
          minValue + ((maxValue - minValue).abs() / (axisCnt - 1)) * index;
      var midValue = minValue + (maxValue - minValue) / 2;
      var digit = 0;
      axisItem.text = (yValue / pow(10, digit)).toStringAsFixed(2);
      axisItem.textFrame = HFRect(rect.minX(), y,
          axisItem.text.length * axisItem.textFontSize, axisItem.textFontSize);
      axisItem.line =
          HFLine(HFPoint(pointRect.minX(), y), HFPoint(pointRect.maxX(), y));
      // axisItem.lineColor = this.leftAxis.lineColor;

      if (yValue > midValue) {
        axisItem.textColor = colorWithValueType(HFValueUpDownType.up);
      } else if (yValue < midValue) {
        axisItem.textColor = colorWithValueType(HFValueUpDownType.down);
      } else {
        axisItem.textColor = colorWithValueType(HFValueUpDownType.equal);
      }

      var rightValue =
          (midValue > 0) ? (yValue - midValue).abs() / midValue * 100 : 0;
      axisItem.extText = '${rightValue.toStringAsFixed(2)}%';
      axisItem.extTextColor = axisItem.textColor;
      axisItem.extTextFrame = HFRect(
          rect.maxX(),
          y,
          axisItem.extText.length * axisItem.extTextFontSize,
          axisItem.textFrame.height);

      if (axisItem.location == HFAxisLocation.head) {
        axisItem.textFrame.top -= axisItem.textFrame.height;
        axisItem.extTextFrame.top = axisItem.textFrame.top;
      } else if (axisItem.location == HFAxisLocation.trail) {
      } else {
        axisItem.textFrame.top -= axisItem.textFrame.height / 2;
        axisItem.extTextFrame.top = axisItem.textFrame.top;
      }
      axisDrawingComps.add(axisItem);
    }
    return axisDrawingComps;
  }

  @override
  List yAxisDataInRect(HFRect rect) {
    var axisCnt = yAxisCnt;
    if (axisCnt < 1) {
      return [];
    }
    var axisDrawingComps = <HFAxisModel>[];
    for (var index = 0; index < axisCnt; index++) {
      if (index == 0 || index == axisCnt - 1) {
        // continue;
      }
      var axisItem = HFAxisModel();
      axisItem.index = index;
      axisItem.axisType = HFAxisType.y;
      axisItem.location = getAxisLocation(index, axisCnt);
      var x = calculatorX(index, 0, axisCnt - 1, pointRect);
      axisItem.line =
          HFLine(HFPoint(x, pointRect.minY()), HFPoint(x, pointRect.maxY()));

      axisDrawingComps.add(axisItem);

      // 不展示y轴坐标值
      // axisItem.text = this.getTextForAxisItem(axisItem)
      // axisItem.textFrame = new XYRect(new XYPoint(x, this.pointRect.maxY()), 60, 20)
    }
    return axisDrawingComps;
  }

  HFAxisLocation getAxisLocation(num index, num totalCnt) {
    if (index == 0) {
      return HFAxisLocation.head;
    } else if (index == totalCnt - 1) {
      return HFAxisLocation.trail;
    }
    return HFAxisLocation.middle;
  }

  @override
  num calculatorX(num forValue, num min, num max, HFRect inRect) {
    num relative = 0.0;
    if (min != max && forValue >= min && forValue <= max) {
      relative = ((forValue - min) / (max - min)) * inRect.width;
    } else if (forValue > max) {
      // 超界
      relative = inRect.width.toDouble();
    }
    return inRect.minX() + relative;
  }

  @override
  num calculatorY(num forValue, num min, num max, HFRect inRect) {
    num relative = 0.0;
    if (min != max && forValue >= min && forValue <= max) {
      relative = ((max - forValue) / (max - min)) * inRect.height;
    } else if (forValue < min) {
      // 超界
      relative = inRect.height;
    }
    return inRect.minY() + relative;
  }
}
