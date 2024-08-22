import 'package:flutter/material.dart';

import '../../Data/HFChartData.dart';
import '../../Data/HFChartDataEntry.dart';
import '../../Data/HFChartDataSet.dart';
import '../../Model/HFChartModel.dart';
import '../../Model/HFGraphicFoundation.dart';
import '../../Providers/HFRectProvider.dart';
import '../../Renderer/HFRectRenderer.dart';
import '../../Canvas/HFCanvasExtension.dart';
import '../HFAxisNode.dart';

/// 成交量指标
class HFTecNodeVolume extends HFAxisNode implements HFRectProvider {
  List<HFChartDataEntry> kline_data = [];
  late HFQuoteBasicEntry basicInfo;
  late HFRectRenderer rectRenderer;
  double infoBarHeight = 20; // 信息条高度
  HFRect _originRect = HFRect.ZERO_RECT;

  HFTecNodeVolume(Canvas canvas) : super(canvas);

  @override
  void initialDefaultSetting() {
    super.initialDefaultSetting();

    rectRenderer = HFRectRenderer(this);
  }

  @override
  set pointRect(HFRect rect) {
    _originRect = rect;
    super.pointRect = HFRect(rect.left, rect.top + infoBarHeight, rect.width,
        rect.height - infoBarHeight);
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
      prePoint = kline_data[startIndex - 1];
    } else {
      // TODO: 取昨收
    }
    for (var i = startIndex; i <= endIndex && i < actualCnt; i++) {
      HFKLineEntry pointData = kline_data[i] as HFKLineEntry;
      // print(pointData.open);
      var rectItem = HFRectModel();
      //偏移，转化到0~visualCount范围中
      var idx = relativeIdxFromIndex(i);
      x = xPoint(idx, pointRect);
      var value = rectValueFor(pointData);
      y = calculatorY(value, minValue, maxValue, pointRect);
      rectItem.candleRect =
          HFRect(x + spacing / 2, y, stepWidth - spacing, pointRect.maxY() - y);
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

    super.data = value;
  }

  @override
  void setNeedsDisplay() {
    super.setNeedsDisplay();
    rectRenderer.draw(pointRect, canvas);
    renderInfoBar(_originRect, canvas);
  }

  /// 绘制指标信息条
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
        var text = 'VOL: ${rectValueFor(itemData)}';

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
  get actualCnt {
    return kline_data.length;
  }

  @override
  num xPoint(num index, HFRect inRect) {
    return super.xPoint(index, inRect);
  }

  num rectValueFor(HFChartDataEntry item) {
    if (item is HFTimeLineEntry) {
      return item.volume;
    } else if (item is HFKLineEntry) {
      return item.volume;
    }
    return 0.0;
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
      var item = kline_data[i];
      value = rectValueFor(item).toDouble();
      if (value != HF_INVALID_VALUE && value > maxV) {
        maxV = value;
      }

      value = 0;
      if (value != HF_INVALID_VALUE && value < minV) {
        minV = value;
      }
    }
    maxValue = (maxV == HF_INTEGER_MIN_VALUE) ? 0 : maxV;
    minValue = (minV == HF_INTEGER_MAX_VALUE) ? 0 : minV;
  }
}
