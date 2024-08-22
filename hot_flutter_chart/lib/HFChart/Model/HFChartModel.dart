import 'dart:ui';
import 'HFGraphicFoundation.dart';

enum HFAxisType {
  x,
  y,
}

enum HFAxisLabelPosition {
  inside,
  outside,
}

enum HFAxisLocation {
  head,
  trail,
  middle,
}

enum HFValueUpDownType {
  up,
  down,
  equal,
}

/// 内部绘制用UI Model
class HFChartModel {
  bool enable = true;
  num index = 0;
  HFPoint point = HFPoint.ZERO_POINT;
  HFLine line = HFLine.ZERO_LINE;
  Color lineColor = const Color(0xFFFD5E53);
  Color fillColor = const Color(0xFFFD5E53);
  double lineBolder = 1;
  String text = "";
  Color textColor = const Color(0xFFFD5E53);
  // FontFeature textFont;
  num textFontSize = 12;
  HFRect textFrame = HFRect.ZERO_RECT;
}

class HFAxisModel extends HFChartModel {
  HFAxisType axisType = HFAxisType.x;
  num labelCnt = 5;
  HFAxisLocation location = HFAxisLocation.head;
  List<num> dash = [2, 1];
  String extText = "";
  Color extTextColor = const Color(0xFFFD5E53);
  // extTextFont: Font
  num extTextFontSize = 12;
  HFRect extTextFrame = HFRect.ZERO_RECT;

  HFAxisModel() {
    lineColor = const Color(0xff4c5c74);
    dash = [];
  }
}

class HFLineModel extends HFChartModel {
  num pointCnt = 0;
  List<HFPoint> points = [];
  List<HFPoint> linePoints = [];
  bool isCurve = true;
  bool isGradient = false;
  bool isDash = false;
}

class HFRectModel extends HFChartModel {
  HFRect candleRect = HFRect.ZERO_RECT;
  num center = 0;
  bool isSolid = true;
  HFLine lineUp = HFLine.ZERO_LINE;
  HFLine lineDown = HFLine.ZERO_LINE;
  HFValueUpDownType valueType = HFValueUpDownType.up;
}

class HFFocusModel extends HFChartModel {
  HFAxisType axisType = HFAxisType.x;
  String extText = "";
  Color extTextColor = const Color(0xFFFD5E53);
  // extTextFont: Font
  num extTextFontSize = 12;
  HFRect extTextFrame = HFRect.ZERO_RECT;

  List<String> appendText = [];
  List<String> alertText = []; // 4 values: high, low, open, close.
}

class HFTextModel extends HFChartModel {
  /// text alignment
  HFAxisLocation location = HFAxisLocation.middle;
}
