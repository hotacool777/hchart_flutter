import 'dart:ui';
import '../Utils/HFUtils.dart';

/// 线图绘制属性
class HFChartConfig {
  bool isLatestPriceLineShow = true; // 显示现价线
  bool isZoomStatisticsShow = false; // 显示区间统计
  bool isAuxiliaryLineShow = false; // 显示画线功能
  bool isLine = false; // K线趋势线模式

  Color backgroundColor = kChartBackgroundColor; // 线图背景色
  double lineWidth = 1;
  double scale = 1; // 初始缩放值
  double scaleMax = 3; // 最大缩放值
  double scaleMin = 0.1; // 最小缩放值

  double indicatorHeight = 60.0; // 副图指标高度
  List<HFIndicatorType> exchangeIndicators = [
    HFIndicatorType.vol,
    HFIndicatorType.macd,
    HFIndicatorType.kdj,
    HFIndicatorType.amount
  ]; // 自动切换指标
  List<HFIndicatorType> indicators = [
    HFIndicatorType.vol,
    HFIndicatorType.macd,
    HFIndicatorType.kdj
  ]; // 副图指标

  HFChartAxisConfig? axisConfig = HFChartAxisConfig();
  List<HFChartConfig> subConfigs = [];

  @override
  String toString() {
    return 'isLatestPriceLineShow: $isLatestPriceLineShow';
  }
}

class HFChartAxisConfig {
  int xAxisCnt = 5;
  int yAxisCnt = 5;

  @override
  String toString() {
    return 'xAxisCnt: $xAxisCnt, yAxisCnt: $yAxisCnt';
  }
}

enum HFIndicatorType {
  none,
  vol,
  amount,
  macd,
  kdj,
  rsi,
}
