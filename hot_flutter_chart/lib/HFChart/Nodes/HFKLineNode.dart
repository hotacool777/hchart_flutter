import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../Data/HFChartData.dart';
import '../Data/HFChartDataEntry.dart';
import '../Data/HFChartDataSet.dart';
import '../Model/HFChartModel.dart';
import '../Model/HFGraphicFoundation.dart';
import '../Providers/HFLineProvider.dart';
import '../Providers/HFRectProvider.dart';
import '../Providers/HFTextProvider.dart';
import '../Renderer/HFLineRenderer.dart';
import '../Renderer/HFRectRenderer.dart';
import '../Renderer/HFTextRenderer.dart';
import 'HFAxisNode.dart';

/// 交易时间轴bar高度
const double HF_KLine_Bar_Height = 16;

class HFKLineNode extends HFAxisNode
    implements HFRectProvider, HFLineProvider, HFTextProvider {
  bool isLatestPriceLineShow = true;
  List<HFKLineEntry> kline_data = [];
  late HFQuoteBasicEntry basicInfo;
  late HFRectRenderer rectRenderer;
  late HFLineRenderer lineRenderer;
  late HFTextRenderer textRenderer;
  Map<num, List> linePointsMap = {};
  List<HFRectModel> rectDrawingData = [];
  List<HFLineModel> lineDrawingData = [];
  num maxPointCnt = 0;
  HFRect _originRect = HFRect.ZERO_RECT;
  double _timeBarHeight = HF_KLine_Bar_Height;
  bool isLine = false; // 趋势线模式
  /// 更新现价线
  final Function? latestPriceLineUpdate;

  HFKLineNode(Canvas canvas, {this.latestPriceLineUpdate}) : super(canvas);

  @override
  set data(HFChartData? value) {
    if (value == null) {
      return;
    }
    var maxCnt = 0;
    var klineDataset = value.getDataSetWithLabel(HF_QUOTE_KLINE_LABEL);
    if (klineDataset != null) {
      kline_data = klineDataset.values as List<HFKLineEntry>;
      maxCnt = kline_data.length;
    }
    var basicDataset = value.getDataSetWithLabel(HF_QUOTE_BASIC_LABEL);
    if (basicDataset != null) {
      if (basicDataset.values.isNotEmpty) {
        basicInfo = basicDataset as HFQuoteBasicEntry;
      }
    }
    // candle数据
    rectDrawingData = [];
    // 线数据
    linePointsMap = {};
    lineDrawingData = [];
    var idxKey = 0;

    if (isLine) {
      // 趋势线模式
      var lineItem = HFLineModel();
      lineItem.isCurve = isCubic;
      lineItem.isGradient = true; // 趋势线阴影渐变
      lineItem.lineColor = const Color(0xff4C86CD);
      lineItem.fillColor = fillColor;
      lineItem.lineBolder = 4;
      lineItem.index = idxKey;
      lineDrawingData.add(lineItem);
      List<HFChartDataEntry> values = [];
      for (var value in kline_data) {
        var point = HFPointEntry.xy(0, value.close);
        values.add(point);
      }
      var points = values;
      if (points.length > 1) {
        linePointsMap[idxKey] = points;
        idxKey++;
      }
    } else {
      // 非趋势线模式
      for (var index = 0; index < value.dataSets.length; index++) {
        var element = value.dataSets[index];
        if (element.label == HF_QUOTE_TIMELINE_LABEL) {
          var lineItem = HFLineModel();
          lineItem.isCurve = isCubic;
          lineItem.isGradient = isGradient;
          lineItem.lineColor = lineColor;
          lineItem.fillColor = fillColor;
          lineItem.lineBolder = lineWidth.toDouble();
          lineItem.index = idxKey;
          lineDrawingData.add(lineItem);
          var points = element.values;
          if (points.length > 1) {
            linePointsMap[idxKey] = points;
            idxKey++;
          }
          if (points.length > maxCnt) {
            maxCnt = points.length;
          }
        }
      }
    }

    maxPointCnt = maxCnt;

    super.data = value;
  }

  @override
  set pointRect(HFRect rect) {
    _originRect = rect;
    super.pointRect =
        HFRect(rect.left, rect.top, rect.width, rect.height - _timeBarHeight);
  }

  @override
  int get actualCnt {
    return max(0, kline_data.length);
  }

  @override
  set actualCnt(int actualCnt) {
    throw Exception('Should NOt set actualCnt in outside.');
  }

  @override
  void initialDefaultSetting() {
    super.initialDefaultSetting();

    xAxisCnt = 3;
    yAxisCnt = 3;

    rectRenderer = HFRectRenderer(this);
    lineRenderer = HFLineRenderer(this);
    textRenderer = HFTextRenderer(this);
  }

  @override
  void setNeedsDisplay() {
    super.setNeedsDisplay();
    if (!isLine) {
      // 趋势线模式不画K线
      rectRenderer.draw(pointRect, canvas);
    }
    lineRenderer.draw(pointRect, canvas);
    textRenderer.draw(pointRect, canvas);
  }

  @override
  List lineDataInRect(HFRect rect) {
    if (lineDrawingData.isEmpty || actualCnt < 1) {
      return [];
    }
    // this.pointRect = rect;
    updateStepWidth();

    double latestY = 0;

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

    // add 现价线
    if (isLatestPriceLineShow) {
      HFLineModel latestPriceLine = HFLineModel();
      latestPriceLine.isDash = true;
      latestPriceLine.lineColor = const Color(0xff4C86CD);
      latestPriceLine.lineBolder = 2;

      var lastItem = kline_data.last;
      var latestPrice = lastItem.close;
      var latestPriceY =
          calculatorY(latestPrice, minValue, maxValue, pointRect).toDouble();
      List<HFPoint> newPoints = [];
      // 现价取值处理
      newPoints.add(HFPoint(pointRect.left, latestPriceY));
      newPoints.add(HFPoint(pointRect.maxX(), latestPriceY));
      latestPriceLine.points = newPoints;

      allLineModel.add(latestPriceLine);
      // 通知外部更新现价线label
      if (latestPriceLineUpdate != null) {
        if (newPoints.isNotEmpty) {
          latestPriceLineUpdate!(newPoints.first, latestPrice);
        } else {
          latestPriceLineUpdate!(HFPoint.INVALID_POINT, latestPrice);
        }
      }
    }

    return allLineModel;
  }

  @override
  List rectDataInRect(HFRect rect) {
    if (kline_data.isEmpty || actualCnt < 1) {
      return [];
    }
    // 计算单元格宽度
    // this.pointRect = rect;
    updateStepWidth();

    num x, open, close, maxV, minV = 0.0;
    var prePoint;
    if (startIndex > 0 && startIndex < kline_data.length) {
      prePoint = kline_data[startIndex - 1];
    } else {
      // TODO: 取昨收
    }
    // print('start: ' + this.startIndex.toString() + ', end: ' +
    //     this.endIndex.toString() + ', actual: ' + this.actualCnt.toString());
    for (var i = startIndex; i <= endIndex && i < actualCnt; i++) {
      HFKLineEntry pointData = kline_data[i];
      // print(pointData.open);
      var rectItem = HFRectModel();
      rectItem.valueType = calculatorValueType(pointData, prePoint);
      rectItem.lineColor = colorWithValueType(rectItem.valueType);
      rectItem.isSolid = true;
      //偏移，转化到0~visualCount范围中
      var idx = relativeIdxFromIndex(i);
      x = xPoint(idx, pointRect);
      open = calculatorY(pointData.open, minValue, maxValue, pointRect);
      close = calculatorY(pointData.close, minValue, maxValue, pointRect);
      maxV = calculatorY(pointData.high, minValue, maxValue, pointRect);
      minV = calculatorY(pointData.low, minValue, maxValue, pointRect);
      rectItem.candleRect = HFRect(x + spacing / 2, min(open, close),
          stepWidth - spacing, max(1, (open - close).abs()));
      rectItem.center = rectItem.candleRect.center().x;

      HFLine upLine, downLine;
      if (rectItem.valueType == HFValueUpDownType.up) {
        upLine = HFLine.generate(rectItem.center, maxV, rectItem.center, close);
        downLine =
            HFLine.generate(rectItem.center, minV, rectItem.center, open);
      } else {
        upLine = HFLine.generate(rectItem.center, maxV, rectItem.center, open);
        downLine =
            HFLine.generate(rectItem.center, minV, rectItem.center, close);
      }
      rectItem.lineUp = upLine;
      rectItem.lineDown = downLine;

      rectDrawingData.add(rectItem);
      prePoint = pointData;
    }
    return rectDrawingData;
  }

  @override
  List<HFTextModel> textDataInRect(HFRect rect) {
    if (kline_data.isEmpty || actualCnt < 1) {
      return [];
    }
    List<HFTextModel> textDrawingData = [];
    int totalCnt = kline_data.length;
    if (startIndex < totalCnt && endIndex < totalCnt) {
      HFTextModel head = HFTextModel();
      head.location = HFAxisLocation.head;
      head.text = kline_data[startIndex].date;
      head.text = head.text.substring(0, head.text.length - 3);
      head.textFrame = HFRect(_originRect.left,
          _originRect.height - _timeBarHeight + 4, 50, _timeBarHeight);
      textDrawingData.add(head);

      HFTextModel middle = HFTextModel();
      middle.location = HFAxisLocation.middle;
      middle.text = kline_data[(startIndex + endIndex) ~/ 2].date;
      middle.text = middle.text.substring(0, middle.text.length - 3);
      middle.textFrame = HFRect(_originRect.left + _originRect.width / 2,
          _originRect.height - _timeBarHeight + 4, 50, _timeBarHeight);
      textDrawingData.add(middle);

      HFTextModel end = HFTextModel();
      end.location = HFAxisLocation.trail;
      end.text = kline_data[endIndex].date;
      end.text = end.text.substring(0, end.text.length - 3);
      end.textFrame = HFRect(_originRect.width,
          _originRect.height - _timeBarHeight + 4, 50, _timeBarHeight);
      textDrawingData.add(end);
    }
    return textDrawingData;
  }

  @override
  void calculateLimitValue() {
    super.calculateLimitValue();
    if (kline_data.isEmpty) {
      return;
    }
    double maxV = HF_INTEGER_MIN_VALUE.toDouble();
    double minV = HF_INTEGER_MAX_VALUE.toDouble();
    var value;
    for (var i = startIndex; i <= endIndex && i < actualCnt; i++) {
      var klineData = kline_data[i];
      var maxKline = klineData.high;
      var maxIdx = maxKline;
      value = (maxIdx != HF_INVALID_VALUE) ? max(maxKline, maxIdx) : maxKline;
      if (value != HF_INVALID_VALUE && value > maxV) {
        maxV = value;
      }
      var minKline = klineData.low;
      var minIdx = minKline;
      value = (minIdx != HF_INVALID_VALUE) ? min(minKline, minIdx) : minKline;
      if (value != HF_INVALID_VALUE && value < minV) {
        minV = value;
      }
    }
    maxValue = (maxV == HF_INTEGER_MIN_VALUE) ? 0 : maxV;
    minValue = (minV == HF_INTEGER_MAX_VALUE) ? 0 : minV;
    //三个点值相同时，涨跌幅按25%展示
    if ((maxValue - minValue).abs() < 0.0001) {
      var base = maxValue;
      maxValue = base * 1.25;
      minValue = base * 0.75;
    }
  }

  HFValueUpDownType calculatorValueType(
      HFKLineEntry current, HFKLineEntry? pre) {
    var close = current.close; // 当前收盘价
    var open = current.open; // 当前开盘价
    if (close > open) {
      return HFValueUpDownType.up;
    } else if (close < open) {
      return HFValueUpDownType.down;
    } else {
      if (pre != null) {
        open = pre.close; // 前一日收盘价
      }

      if (close >= open) {
        // 相等默认为涨色
        return HFValueUpDownType.up;
      } else {
        return HFValueUpDownType.down;
      }
    }
  }

  /// 对应柱图的x
  num xPointInRect(num index, HFRect inRect) {
    var x = super.xPoint(index, inRect);
    if (isCenter) {
      x += stepWidth / 2;
    }
    return x;
  }

  num lineValueForItem(HFPointEntry entry, num index) {
    return entry.y;
  }

  @override
  int indexAtChartForPoint(HFPoint point) {
    if (stepWidth <= 0) return -1;
    var focusIndex = super.indexAtChartForPoint(point);

    double offsetX = point.x - pointRect.minX().toDouble();
    focusIndex = offsetX ~/ stepWidth;
    // 超界处理
    if (lineDrawingData.isNotEmpty) {
      HFLineModel lineItems = lineDrawingData[0];
      if (focusIndex > 0 && focusIndex >= lineItems.points.length) {
        focusIndex = lineItems.points.length - 1;
      }
    }
    return focusIndex > 0 ? focusIndex : 0;
  }

  @override
  HFPoint pointAtChartForIndex(int index) {
    HFPoint point = super.pointAtChartForIndex(index);
    if (isLine) {
      // 趋势线取line
      if (lineDrawingData.isNotEmpty) {
        HFLineModel element = lineDrawingData[0];
        if (element.points.length > index) {
          var lineItems = element.points[index];
          point.x = lineItems.x;
          point.y = lineItems.y;
        }
      }
    } else {
      if (rectDrawingData.isNotEmpty) {
        var lineItems = rectDrawingData[index];
        point.x = lineItems.candleRect.left + lineItems.candleRect.width / 2;
        point.y = lineItems.candleRect.top;
        if (lineItems.valueType == HFValueUpDownType.down) {
          point.y += lineItems.candleRect.height;
        }
      }
    }

    return point;
  }

  @override
  HFChartDataEntry? dataAtChartForPoint(HFPoint point) {
    var itemData = dataAtChartForIndex(indexAtChartForPoint(point));
    itemData ??= super.dataAtChartForPoint(point);
    return itemData;
  }

  @override
  HFChartDataEntry? dataAtChartForIndex(int index) {
    var itemData = super.dataAtChartForIndex(index);
    if (index < kline_data.length) {
      itemData = kline_data[index];
    }
    return itemData;
  }

  @override
  double contentWidth() {
    double scrollContentWidth = actualCnt.toDouble() * stepWidth;
    return scrollContentWidth > 0 ? scrollContentWidth : super.contentWidth();
  }
}
