import 'dart:ui';

// 值不存在时，设置的默认无效值
const int HF_INVALID_VALUE = -686868;
// 浮点0值
const double HF_FLOAT_ZERO_VALUE = 0.00001;
// 最大整数值
const int HF_INTEGER_MAX_VALUE = 686868;
// 最小整数值
const int HF_INTEGER_MIN_VALUE = -686868;

const String HF_NULL_VALUE = '--';

class HFPoint {
  static final HFPoint ZERO_POINT = HFPoint(0, 0);
  static final HFPoint INVALID_POINT =
      HFPoint(HF_INVALID_VALUE, HF_INVALID_VALUE);

  late num x;
  late num y;

  HFPoint(this.x, this.y);

  bool isValid() {
    if (x == HF_INVALID_VALUE || y == HF_INVALID_VALUE) {
      return false;
    }
    return true;
  }

  bool isZero() {
    if (x != 0 || y != 0) {
      return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'x: $x, y: $y';
  }
}

class HFLine {
  static final HFLine ZERO_LINE = HFLine.generate(0, 0, 0, 0);
  late HFPoint start;
  late HFPoint end;

  HFLine(this.start, this.end);

  HFLine.generate(num x0, num y0, num x1, num y1) {
    start = HFPoint(x0, y0);
    end = HFPoint(x1, y1);
  }

  HFLine.generateVLine(this.start, num width) {
    end = HFPoint(start.x + width, start.y);
  }

  HFLine.generateHLine(this.start, num height) {
    end = HFPoint(start.x, start.y + height);
  }
}

class HFRect {
  static final HFRect ZERO_RECT = HFRect(0, 0, 0, 0);
  num left;
  num top;
  num width;
  num height;

  HFRect(this.left, this.top, this.width, this.height);

  HFPoint origin() {
    return HFPoint(left, top);
  }

  HFPoint center() {
    return HFPoint(left + width / 2, top + height / 2);
  }

  num minY() {
    return top;
  }

  num maxY() {
    return top + height;
  }

  num minX() {
    return left;
  }

  num maxX() {
    return left + width;
  }

  Rect rect() {
    return Rect.fromLTWH(
        left.toDouble(), top.toDouble(), width.toDouble(), height.toDouble());
  }

  bool isValid() {
    if (center().x == HF_INVALID_VALUE || center().y == HF_INVALID_VALUE) {
      return false;
    }
    return true;
  }

  bool isPointInRect(HFPoint point) {
    if (left <= point.x &&
        maxX() >= point.x &&
        top <= point.y &&
        maxY() >= point.y) {
      return true;
    }
    return false;
  }

  @override
  String toString() {
    return "HFRect>> l: $left, t: $top, w: $width, h: $height.";
  }
}
