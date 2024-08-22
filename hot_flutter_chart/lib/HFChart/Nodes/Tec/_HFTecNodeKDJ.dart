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

/// KDJ指标
class HFTecNodeKDJ extends HFTecNodeVolume implements HFLineProvider {
  HFTecNodeKDJ(Canvas canvas) : super(canvas);

  // kdj points
  List<HFPointEntry> k_points = [];
  List<HFPointEntry> d_points = [];
  List<HFPointEntry> j_points = [];

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
      var tecValues = calculate_kdj(originData, 9, 3, 3);
      k_points = [];
      d_points = [];
      j_points = [];
      for (int i = 0; i < tecValues.length; i++) {
        k_points.add(HFPointEntry.xy(i, tecValues[i].k));
        d_points.add(HFPointEntry.xy(i, tecValues[i].d));
        j_points.add(HFPointEntry.xy(i, tecValues[i].j));
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
      points = k_points;
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
      points = d_points;
      if (points.length > 1) {
        linePointsMap[idxKey] = points;
        idxKey++;
      }
      lineItem = HFLineModel();
      lineItem.isCurve = isCubic;
      lineItem.isGradient = isGradient;
      lineItem.lineColor = Colors.yellow;
      lineItem.fillColor = fillColor;
      lineItem.lineBolder = lineWidth.toDouble();
      lineItem.index = idxKey;
      lineDrawingData.add(lineItem);
      points = j_points;
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
    // 不画rect
    return [];
  }

  @override
  List lineDataInRect(HFRect rect) {
    if (lineDrawingData.isEmpty || actualCnt < 1) {
      return [];
    }
    // this.pointRect = rect;
    updateStepWidth();

    double latestY = 0;
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

        latestY = y;
      }
      element.points = newPoints;
    }

    List<HFLineModel> allLineModel = [];
    allLineModel.addAll(lineDrawingData);

    return allLineModel;
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
      double k = k_points[i].y.toDouble();
      double d = d_points[i].y.toDouble();
      double j = j_points[i].y.toDouble();
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
            'KDJ: (${k_points[focusIndex].y.toStringAsFixed(3)}, ${d_points[focusIndex].y.toStringAsFixed(3)}, ${j_points[focusIndex].y.toStringAsFixed(3)})';

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
    if (item is HFTimeLineEntry) {
      return item.money;
    } else if (item is HFKLineEntry) {
      return item.money;
    }
    return 0.0;
  }

  num lineValueForItem(HFPointEntry entry, num index) {
    return entry.y;
  }
}
