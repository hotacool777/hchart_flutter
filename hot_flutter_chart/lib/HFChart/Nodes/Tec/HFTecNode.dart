import 'dart:ui';

import 'package:flutter/material.dart';

import '../../Configs/HFChartConfig.dart';
import '../../Data/HFChartData.dart';
import '../../Model/HFGraphicFoundation.dart';
import '../HFAxisNode.dart';
import '../HFChartNode.dart';
import '_HFTecNodeAmount.dart';
import '_HFTecNodeKDJ.dart';
import '_HFTecNodeMACD.dart';
import '_HFTecNodeVolume.dart';

/// 副图指标类，以类簇方式提供公共tec类
class HFTecNode extends HFAxisNode {
  HFIndicatorType _tecType = HFIndicatorType.none;
  HFChartNode? _tecNode;

  HFTecNode(Canvas canvas) : super(canvas);

  @override
  void initialDefaultSetting() {
    super.initialDefaultSetting();
    xAxisCnt = 3;
    yAxisCnt = 3;
  }

  @override
  set data(HFChartData? value) {
    if (value == null) {
      return;
    }
    final tecNode = _tecNode;
    if (tecNode != null) {
      tecNode.xAxisCnt = xAxisCnt;
      tecNode.yAxisCnt = yAxisCnt;
      tecNode.data = value;
    }
    super.data = value;
  }

  @override
  void setNeedsDisplay() {
    final tecNode = _tecNode;
    if (tecNode != null) {
      tecNode.setNeedsDisplay();
    }
  }

  @override
  set focusIndex(int value) {
//print('focusIndex' + value.toString());
    super.focusIndex = value;
    final tecNode = _tecNode;
    if (tecNode != null) {
//print('focusIndex' + this.focusIndex.toString());
      tecNode.focusIndex = value;
    }
  }

  @override
  set pointRect(HFRect value) {
    super.pointRect = value;
    final tecNode = _tecNode;
    if (tecNode != null) {
      tecNode.pointRect = value;
    }
  }

  // set actualCnt(int value);

  @override
  set visualCnt(int value) {
    super.visualCnt = value;
    final tecNode = _tecNode;
    if (tecNode != null) {
      tecNode.visualCnt = value;
    }
  }

  @override
  set startIndex(int value) {
    super.startIndex = value;
    final tecNode = _tecNode;
    if (tecNode != null) {
      tecNode.startIndex = value;
    }
  }

  @override
  set endIndex(int value) {
    super.endIndex = value;
    final tecNode = _tecNode;
    if (tecNode != null) {
      tecNode.endIndex = value;
    }
  }

  set tecType(HFIndicatorType type) {
    if (_tecType != type) {
      var newNode = createTecNode(type);
      newNode.data = data;
      newNode.pointRect = pointRect;
      newNode.visualCnt = visualCnt;
      newNode.startIndex = startIndex;
      newNode.endIndex = endIndex;
      _tecNode = newNode;
      _tecType = type;
    }
  }

  HFIndicatorType get tecType {
    return _tecType;
  }

  HFChartNode createTecNode(HFIndicatorType type) {
    HFTecNodeVolume tecNode;
    switch (type) {
      case HFIndicatorType.vol:
        tecNode = HFTecNodeVolume(canvas);
        break;
      case HFIndicatorType.amount:
        tecNode = HFTecNodeAmount(canvas);
        break;
      case HFIndicatorType.kdj:
        tecNode = HFTecNodeKDJ(canvas);
        break;
      case HFIndicatorType.macd:
        tecNode = HFTecNodeMACD(canvas);
        break;
      default:
        tecNode = HFTecNodeVolume(canvas);
        break;
    }
    return tecNode;
  }

  /// 判断点是否在当前view中
  HFTecNode? hitTestWith(HFPoint point) {
    if (pointRect.isPointInRect(point)) {
      return this;
    }
    return null;
  }
}
