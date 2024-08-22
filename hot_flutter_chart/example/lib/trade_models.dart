import 'package:hot_flutter_chart/HFChart/hot_flutter_chart.dart';

// 显示名称
const String HF_DISPLAY_LABEL_OPEN = '今开';
const String HF_DISPLAY_LABEL_LAST = '现价';
const String HF_DISPLAY_LABEL_HIGH = '最高';
const String HF_DISPLAY_LABEL_LOW = '最低';
const String HF_DISPLAY_LABEL_PRE = '昨收';
const String HF_DISPLAY_LABEL_VOLUME = '成交量';
const String HF_DISPLAY_LABEL_AMOUNT = '成交额';
const String HF_DISPLAY_LABEL_FLOW_VALUE = '流通市值';
const String HF_DISPLAY_LABEL_CHANGE = '涨跌';
const String HF_DISPLAY_LABEL_CHANGE_RATE = '涨跌额';
const String HF_DISPLAY_LABEL_TURNOVER_RATE = '换手率';
const String HF_DISPLAY_LABEL_TTM = '市盈率';
const String HF_DISPLAY_LABEL_PE = '市盈动';
const String HF_DISPLAY_LABEL_SPE = '市盈静';

class HFTradeOHLCItem {
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

  HFTradeOHLCItem copy() {
    HFTradeOHLCItem newOne = HFTradeOHLCItem();
    newOne.date = date;
    newOne.open = open;
    newOne.high = high;
    newOne.low = low;
    newOne.close = close;
    newOne.avgPrice = avgPrice;
    newOne.money = money;
    newOne.volume = volume;
    newOne.totalVolume = totalVolume;
    newOne.totalMoney = totalMoney;
    newOne.changeRate = changeRate;
    return newOne;
  }

  @override
  String toString() {
    return 'date: $date, last: $close';
  }
}

/// 行情数据Model
class HFTradeItem {
  // 名称
  String name = '';
  // 日期
  String date = '';
  // 开
  num open = 0;
  // 昨收
  num pre = 0;
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
  // 换手率
  num turnoverRate = 0;
  // 当前总成交量
  num totalVolume = 0;
  // 当前总成交金额
  num totalMoney = 0;
  // 涨跌幅
  num change = 0;
  // 涨跌幅比例
  num changeRate = 0;
  // 市盈率（TTM）
  num TTM = 0;
  // PE(市盈 动)
  num PE = 0;
  // SPE(市盈 静)
  num SPE = 0;
  // 总市值
  num totalValue = 0;
  // 流通市值
  num flowValue = 0;
  // 总股本 单位:股
  num capitalization = 0;
  // 流通股 单位:股
  num circulatingShare = 0;

  String getDisplayValue(String key) {
    switch(key) {
      case HF_DISPLAY_LABEL_OPEN:
        return open.toString();
      case HF_DISPLAY_LABEL_LAST:
        return close.toString();
      case HF_DISPLAY_LABEL_HIGH:
        return high.toString();
      case HF_DISPLAY_LABEL_LOW:
        return low.toString();
      case HF_DISPLAY_LABEL_PRE:
        return pre.toString();
      case HF_DISPLAY_LABEL_VOLUME:
        return volume.toString();
      case HF_DISPLAY_LABEL_AMOUNT:
        return totalMoney.toString();
      case HF_DISPLAY_LABEL_CHANGE:
        return change.toString();
      case HF_DISPLAY_LABEL_CHANGE_RATE:
        return changeRate.toString();
      case HF_DISPLAY_LABEL_TURNOVER_RATE:
        return turnoverRate.toString();
      case HF_DISPLAY_LABEL_TTM:
        return TTM.toString();
      case HF_DISPLAY_LABEL_PE:
        return PE.toString();
      case HF_DISPLAY_LABEL_SPE:
        return SPE.toString();
      case HF_DISPLAY_LABEL_FLOW_VALUE:
        return flowValue.toString();
    }
    return '';
  }

  @override
  String toString() {
    return 'date: $date, close: $close';
  }
}

extension HFTradeOHLCItemToEntry on HFTradeOHLCItem {
  HFKLineEntry transformToKlineEntry() {
    var pointData = HFKLineEntry();
    // print(item.toString());
    // pointData.date = int.parse(item.day);
    pointData.date = date;
    pointData.open = open;
    pointData.high = high;
    pointData.low = low;
    pointData.close = close;
    pointData.volume = volume;
    pointData.money = money;
    return pointData;
  }
}