import 'dart:core';

class HFChartDataEntry {}

class HFPointEntry extends HFChartDataEntry {
  num x = 0;
  num y = 0;

  HFPointEntry();

  HFPointEntry.xy(this.x, this.y);

  @override
  String toString() {
    return 'x: $x, y: $y';
  }
}

class HFTimeLineEntry extends HFPointEntry {
  // 日期
  num date = 0;
  // 当前最新价
  num latestPrice = 0;
  // 平均价
  num avgPrice = 0;
  // 成交金额
  num money = 0;
  // 成交量
  num volume = 0;
  // 当前总成交量
  num totalVolume = 0;
  // 当前总成交金额
  num totalMoney = 0;
  // 涨跌幅比例
  num changeRate = 0;
}

class HFKLineEntry extends HFPointEntry {
  // 日期
  String date = '';
  // 开
  num open = 0;
  // 高
  num high = 0;
  // 低
  num low = 0;
  // 收
  num close = 0;
  // 平均价
  num avgPrice = 0;
  // 成交金额
  num money = 0;
  // 成交量
  num volume = 0;
  // 当前总成交量
  num totalVolume = 0;
  // 当前总成交金额
  num totalMoney = 0;
  // 涨跌幅比例
  num changeRate = 0;

  @override
  String toString() {
    return 'date: $date, open: $open';
  }
}

class HFQuoteBasicEntry extends HFChartDataEntry {
  // 价格小数位数
  int priceDigit = 3;
  // 成交量小数位数
  int volumeDigit = 0;
  // 手数, default 100
  int handUnit = 100;
  //对股票是昨收，对期货是昨结
  num previousPrice = 0;
  // 开盘价
  num openPrice = 0;
  // 开市总时间
  int totalTime = 0;
  //交易时间段
  List<String> tradePeriodArr = ["9:30", "11:30", "13:00", "15:00"];
}

/// 副图技术指标数值
class HFTecIndexEntry extends HFChartDataEntry {
  double value = 0;

  HFTecIndexEntry(this.value);
}

/// MA指标值
class HFTecMAEntry extends HFTecIndexEntry {
  double ma1 = 0;
  double ma2 = 0;
  double ma3 = 0;

  HFTecMAEntry(this.ma1, this.ma2, this.ma3) : super(0.0);
}

/// KDJ指标值
class HFTecKDJEntry extends HFTecIndexEntry {
  double k = 0;
  double d = 0;
  double j = 0;

  HFTecKDJEntry(this.k, this.d, this.j) : super(0.0);

  HFTecKDJEntry.zero() : super(0.0);
}

/// MACD指标值
class HFTecMACDEntry extends HFTecIndexEntry {
  double dDIF = 0;
  double dDEA = 0;
  double dMacd = 0;

  HFTecMACDEntry(this.dDIF, this.dDEA, this.dMacd) : super(0.0);

  HFTecMACDEntry.zero() : super(0.0);
}
