import 'dart:math';

import 'package:flutter/material.dart';
import '../../Canvas/HFCanvasExtension.dart';
import '../../Data/HFChartData.dart';
import '../../Data/HFChartDataEntry.dart';
import '../../Data/HFChartDataSet.dart';
import '../../Model/HFChartModel.dart';
import '../../Model/HFGraphicFoundation.dart';
import '../../Providers/HFLineProvider.dart';
import '../../Renderer/HFLineRenderer.dart';
import '../../Utils/HFTecCalculator.dart';
import '_HFTecNodeVolume.dart';

/// MACD指标
class HFTecNodeMACD extends HFTecNodeVolume implements HFLineProvider {
  HFTecNodeMACD(Canvas canvas) : super(canvas);

  // points
  List<HFTecMACDEntry> tec_values = [];
  List<HFPointEntry> dif_points = [];
  List<HFPointEntry> dea_points = [];

  // line renderer
  late HFLineRenderer lineRenderer;
  Map<num, List> linePointsMap = {};
  List<HFLineModel> lineDrawingData = [];

  @override
  void initialDefaultSetting() {
    super.initialDefaultSetting();

    lineRenderer = HFLineRenderer(this);
  }

  @override
  set data(HFChartData? value) {
    if (value == null) {
      return;
    }
    // 计算指标
    var klineDataset = value.getDataSetWithLabel(HF_QUOTE_KLINE_LABEL);
    if (klineDataset != null) {
      var originData = klineDataset.values as List<HFKLineEntry>;
      tec_values = calculate_macd(originData, 12, 26, 9);
      dif_points = [];
      dea_points = [];
      for (int i = 0; i < tec_values.length; i++) {
        dif_points.add(HFPointEntry.xy(i, tec_values[i].dDIF));
        dea_points.add(HFPointEntry.xy(i, tec_values[i].dDEA));
      }
      // 线数据
      linePointsMap = {};
      lineDrawingData = [];
      var idxKey = 0;
      List<HFPointEntry> points;
      HFLineModel lineItem;
      lineItem = HFLineModel();
      lineItem.isCurve = isCubic;
      lineItem.isGradient = isGradient;
      lineItem.lineColor = Colors.pink;
      lineItem.fillColor = fillColor;
      lineItem.lineBolder = lineWidth.toDouble();
      lineItem.index = idxKey;
      lineDrawingData.add(lineItem);
      points = dif_points;
      if (points.length > 1) {
        linePointsMap[idxKey] = points;
        idxKey++;
      }
      lineItem = HFLineModel();
      lineItem.isCurve = isCubic;
      lineItem.isGradient = isGradient;
      lineItem.lineColor = Colors.blue;
      lineItem.fillColor = fillColor;
      lineItem.lineBolder = lineWidth.toDouble();
      lineItem.index = idxKey;
      lineDrawingData.add(lineItem);
      points = dea_points;
      if (points.length > 1) {
        linePointsMap[idxKey] = points;
        idxKey++;
      }
    }

    super.data = value;
  }

  @override
  void setNeedsDisplay() {
    super.setNeedsDisplay();
    lineRenderer.draw(pointRect, canvas);
  }

  @override
  List rectDataInRect(HFRect rect) {
    if (kline_data.isEmpty || actualCnt < 1) {
      return [];
    }
    // 计算单元格宽度
    updateStepWidth();

    var rectDrawingData = [];
    num x, y = 0.0;
    var prePoint;
    if (startIndex > 0 && startIndex < kline_data.length) {
      prePoint = tec_values[startIndex - 1];
    } else {
      // TODO: 取昨收
    }
    for (var i = startIndex; i <= endIndex && i < actualCnt; i++) {
      HFTecMACDEntry pointData = tec_values[i];
      // print(pointData.open);
      var rectItem = HFRectModel();
      //偏移，转化到0~visualCount范围中
      var idx = relativeIdxFromIndex(i);
      x = xPoint(idx, pointRect);
      var value = rectValueFor(pointData);
      // y轴0点
      var originY = calculatorY(0, minValue, maxValue, pointRect);
      y = ((value) / (maxValue - minValue)) * pointRect.height;
      rectItem.candleRect =
          HFRect(x + spacing / 2, originY, stepWidth - spacing, -y);
      rectItem.valueType = calculatorValueType(pointData, prePoint);
      rectItem.lineColor = colorWithValueType(rectItem.valueType);
      rectItem.center = rectItem.candleRect.center().x;

      rectDrawingData.add(rectItem);
      prePoint = pointData;
    }
    // print('tecNode: ' + rectDrawingData.toString());
    return rectDrawingData;
  }

  @override
  List lineDataInRect(HFRect rect) {
    if (lineDrawingData.isEmpty || actualCnt < 1) {
      return [];
    }
    // this.pointRect = rect;
    updateStepWidth();

    // TODO: 需剔除未达到周期的无效点
    for (var index = 0; index < lineDrawingData.length; index++) {
      HFLineModel element = lineDrawingData[index];
      var points = linePointsMap[index];
      if (points == null || points.isEmpty) {
        continue;
      }
      element.pointCnt = endIndex - startIndex + 1;
      List<HFPoint> newPoints = [];
      for (var i = startIndex; i <= endIndex && i < actualCnt; i++) {
        if (i >= points.length) {
          break;
        }
        var p = points[i];
        double x, y = 0.0;
        var idx = relativeIdxFromIndex(i);
        x = xPoint(idx, pointRect).toDouble();
        if (isCenter) {
          x += stepWidth / 2;
        }
        var value = lineValueForItem(p, element.index);
        y = calculatorY(value, minValue, maxValue, pointRect).toDouble();
        newPoints.add(HFPoint(x, y));
      }
      element.points = newPoints;
    }

    List<HFLineModel> allLineModel = [];
    allLineModel.addAll(lineDrawingData);

    return allLineModel;
  }

  @override
  HFValueUpDownType calculatorValueType(
      HFChartDataEntry current, HFChartDataEntry? pre) {
    if (current is HFTecMACDEntry) {
      if (current.dMacd > 0) {
        return HFValueUpDownType.up;
      }
    }
    return HFValueUpDownType.down;
  }

  @override
  void calculateLimitValue() {
    super.calculateLimitValue();
    if (kline_data.isEmpty) {
      return;
    }
    double maxV = HF_INTEGER_MIN_VALUE.toDouble();
    double minV = HF_INTEGER_MAX_VALUE.toDouble();
    double value;
    for (var i = startIndex; i <= endIndex && i < actualCnt; i++) {
      double k = tec_values[i].dDIF.toDouble();
      double d = tec_values[i].dDEA.toDouble();
      double j = tec_values[i].dMacd.toDouble();
      value = max(max(k, d), j);
      maxV = max(maxV, value);

      value = min(min(k, d), j);
      minV = min(minV, value);
    }
    maxValue = (maxV == HF_INTEGER_MIN_VALUE) ? 0 : maxV;
    minValue = (minV == HF_INTEGER_MAX_VALUE) ? 0 : minV;
  }

  @override
  void renderInfoBar(HFRect inRect, Canvas canvas) {
    if (kline_data.isEmpty) {
      return;
    }
    var focusIndex =
        this.focusIndex == -1 ? kline_data.length - 1 : this.focusIndex;
    if (focusIndex < kline_data.length) {
      var itemData = kline_data[focusIndex];
      if (itemData is HFKLineEntry) {
        // K 线
        HFKLineEntry klineData = itemData;
        var text =
            'MACD: (${tec_values[focusIndex].dDIF.toStringAsFixed(3)}, ${tec_values[focusIndex].dDEA.toStringAsFixed(3)}, ${tec_values[focusIndex].dMacd.toStringAsFixed(3)})';

        Paint paint = Paint()..style = PaintingStyle.stroke;
        TextStyle textStyle = const TextStyle(
            color: Colors.black, backgroundColor: Colors.white, fontSize: 10);
        canvas.drawText(
            paint,
            " $text ",
            Offset(inRect.left.toDouble(),
                inRect.top.toDouble() + (infoBarHeight - 10 - 4)),
            textStyle: textStyle,
            drawOrigin: 0);
      }
    }
  }

  @override
  num rectValueFor(HFChartDataEntry item) {
    if (item is HFTecMACDEntry) {
      return item.dMacd;
    }
    return 0.0;
  }

  num lineValueForItem(HFPointEntry entry, num index) {
    return entry.y;
  }
}
