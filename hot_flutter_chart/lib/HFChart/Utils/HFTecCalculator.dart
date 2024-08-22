import 'dart:math';

import '../Data/HFChartDataEntry.dart';

/// 计算 SMA，即简单移动平均（Simple Moving Average）。
List<HFTecIndexEntry> calculate_sma(List<double> prices, int period) {
  /**
  计算简单移动平均
    :param prices: 价格列表，例如：[收盘价1, 收盘价2, ..., 收盘价n]
    :param period: 移动平均的周期，例如：30
    :return: SMA值列表
  */
  if (period < 1) {
    return [];
  }
  if (prices.length < period) {
    // 数据必须大于周期
    return [];
  }
  List<HFTecIndexEntry> values = [];
  double sum = 0; // 周期求和
  for (int i = 0; i < prices.length; i++) {
    sum += prices[i];
    if (i < period - 1) {
      values.add(HFTecIndexEntry(0));
    }
    if (i - period + 1 > 0) {
      sum -= prices[i - period]; // 减去第一个
    }
    var ma = HFTecIndexEntry(sum / period);
    values.add(ma);
  }
  return values;
}

/// 计算 EMA，即指数移动平均线（Exponential Moving Average）。
List<HFTecIndexEntry> calculate_ema(
    List<double> prices, int period, double smoothing) {
  /**
      计算指数移动平均
      :param prices: 价格列表，例如：[收盘价1, 收盘价2, ..., 收盘价n]
      :param period: 移动平均的周期，例如：30
      :param smoothing: 平滑系数，默认为2/(1+period)
      :return: EMA值列表
   */
  if (period < 1) {
    return [];
  }
  if (prices.length < period) {
    // 数据必须大于周期
    return [];
  }
  List<HFTecIndexEntry> values = [];
  int start = period - 1;
  for (int i = 0; i < prices.length; i++) {
    HFTecIndexEntry ma;
    if (i < start) {
      // 未满足周期的值初始化为0
      ma = HFTecIndexEntry(0);
    } else if (i == start) {
      // 初始EMA值使用SMA计算
      var startValue = calculate_sma(prices.sublist(0, period), period);
      ma = startValue.first;
    } else {
      // EMA_today=α×Price_today+(1−α)×EMA_yesterday
      var value = prices[i] * smoothing + values[i - 1].value * (1 - smoothing);
      ma = HFTecIndexEntry(value);
    }
    values.add(ma);
  }
  return values;
}

/// 计算 KDJ，全称为随机指标（Stochastic Indicator）0。
List<HFTecKDJEntry> calculate_kdj(
    List<HFKLineEntry> prices, int period, int smoothK, int smoothD) {
  /**
      计算指数移动平均
      :param prices: 收盘价列表
      :param highs: 最高价列表
      :param lows: 最低价列表
      :param period: KDJ指标的周期，默认为9
      :param smooth_k: K值的平滑参数，默认为3
      :param smooth_d: D值的平滑参数，默认为3
      :return: K, D, J值的列表
   */
  if (prices.length < period) {
    // 数据必须大于周期
    return [];
  }
  List<HFTecKDJEntry> values = [];

  for (int i = 0; i < prices.length; i++) {
    double rsv = 0;
    double close = prices[i].close.toDouble();
    double high = prices[i].high.toDouble();
    double low = prices[i].low.toDouble();
    // 计算RSV
    for (int j = i; j > i - period && j >= 0; j--) {
      high = max(high, prices[j].high.toDouble());
      low = min(low, prices[j].low.toDouble());
    }
    if (high > low) {
      rsv = ((close - low) / (high - low)) * 100.0;
    } else {
      rsv = 0;
    }

    // 计算 kdj
    HFTecKDJEntry kdjEntry = HFTecKDJEntry.zero();
    if (i < period - 1) {
      // HFTecKDJEntry.zero()
    } else {
      // 平滑移动计算
      if (i == period - 1) {
        // 初始值用50替代
        kdjEntry.k = rsv / smoothK + (smoothK - 1) * 50.0 / smoothK;
        kdjEntry.d = kdjEntry.k / smoothD + (smoothD - 1) * 50.0 / smoothD;
      } else {
        kdjEntry.k = values[i - 1].k * (smoothK - 1) / smoothK + rsv / smoothK;
        kdjEntry.d =
            kdjEntry.k / smoothD + values[i - 1].d * (smoothD - 1) / smoothD;
      }
      // 3K - 2D
      kdjEntry.j = 3 * kdjEntry.k - 2 * kdjEntry.d;
    }

    values.add(kdjEntry);
  }
  return values;
}

/// 计算 MACD，即移动平均收敛/发散指标（Moving Average Convergence/Divergence）
List<HFTecMACDEntry> calculate_macd(List<HFKLineEntry> prices, int fastPeriod,
    int slowPeriod, int signalPeriod) {
  List<HFTecMACDEntry> values = [];
  // 计算ema
  get_ema(List<HFKLineEntry> prices, int period) {
    List<double> emas = [];
    for (int i = 0; i < prices.length; i++) {
      double close = prices[i].close.toDouble();
      double ema;
      if (i == 0) {
        ema = 0;
      } else {
        ema = emas[i - 1] * (period - 1.0) / (period + 1.0) +
            close * 2 / (period + 1.0);
      }
      emas.add(ema);
    }
    return emas;
  }

  // 首先计算12日和26日的EMA。对于第一天的EMA，可以使用简单的收盘价平均值作为起始值。
  List<double> fastEma = get_ema(prices, fastPeriod);
  List<double> slowEma = get_ema(prices, slowPeriod);

  // 计算快速线：DIF = EMA(12) - EMA(26)
  double dif = 0;
  for (int i = 0; i < prices.length; i++) {
    dif = fastEma[i] - slowEma[i];
    HFTecMACDEntry macd = HFTecMACDEntry.zero();
    macd.dDIF = dif;
    values.add(macd);
  }

  //　计算慢速线（信号线）：DEA（MACD）
  values[0].dDEA = values[0].dDIF;
  for (int i = 1; i < prices.length; i++) {
    values[i].dDEA =
        values[i - 1].dDEA * (signalPeriod - 1.0) / (signalPeriod + 1.0) +
            values[i].dDIF * 2 / (signalPeriod + 1.0);
  }

  // 计算MACD柱状图
  for (int i = 0; i < prices.length; i++) {
    values[i].dMacd = 2 * (values[i].dDIF - values[i].dDEA);
  }

  return values;
}
