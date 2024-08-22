import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hot_flutter_chart/HFChart/hot_flutter_chart.dart';

import 'trade_models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      scrollBehavior:
          MyCustomScrollBehavior(), // 支持desktop APP时，通过鼠标拖动方式进行scroll滑动。
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// 支持desktop APP时，通过鼠标拖动方式进行scroll滑动。
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late HFChartData _kchartData;
  late HFChartConfig _kchartConfig;

  bool showLoading = true;

  List<HFTradeOHLCItem> _originData = []; // 缓存response
  int count = 0;

  @override
  void initState() {
    super.initState();
    _kchartData = HFChartData([]);
    _kchartConfig = getChartConfig(2);

    reloadKLineData();
  }

  HFChartConfig getChartConfig(int indicatorCnt) {
    HFChartConfig config = HFChartConfig();
    config.scale = 0.5;
    HFChartAxisConfig axisConfig = HFChartAxisConfig();
    axisConfig.xAxisCnt = 5;
    axisConfig.yAxisCnt = 3;
    config.axisConfig = axisConfig;
    switch (indicatorCnt) {
      case 1:
        config.indicators = [HFIndicatorType.vol];
        break;
      case 2:
        config.indicators = [HFIndicatorType.vol, HFIndicatorType.macd];
        break;
      case 3:
        config.indicators = [
          HFIndicatorType.vol,
          HFIndicatorType.macd,
          HFIndicatorType.kdj,
        ];
        break;
      case 4:
        config.indicators = [
          HFIndicatorType.vol,
          HFIndicatorType.macd,
          HFIndicatorType.kdj,
          HFIndicatorType.amount,
        ];
        break;
      default:
        config.indicators = [
          HFIndicatorType.vol,
          HFIndicatorType.macd,
          HFIndicatorType.kdj
        ];
    }
    return config;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff17212F),
      body: SizedBox(
        height: 800,
        child: Column(
          children: <Widget>[
            Stack(children: <Widget>[
              Visibility(
                visible: _kchartData.dataSets.isNotEmpty,
                child: Container(
                  height: 450,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: HFKLineView(
                    data: _kchartData, // 设置线图数据
                    config: _kchartConfig, // 设置线图UI
                  ),
                ),
              ),
              if (showLoading)
                Container(
                    width: double.infinity,
                    height: 450,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator()),
            ]),
            Container(
              height: 6,
            ),
            buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget buildButtons() {
    getOpenOrClose(bool flag) {
      return flag ? '开' : '关';
    }

    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      spacing: 5,
      children: <Widget>[
        button("副图[${_kchartConfig.indicators.length}]", onPressed: () {
          setState(() {
            int cnt = Random().nextInt(5);
            _kchartConfig = getChartConfig(cnt);
          });
        }),
        button("现价线[${getOpenOrClose(_kchartConfig.isLatestPriceLineShow)}]",
            onPressed: () {
          setState(() {
            _kchartConfig.isLatestPriceLineShow =
                !_kchartConfig.isLatestPriceLineShow;
          });
        }),
        button("缩放+", onPressed: () {
          setState(() {
            _kchartConfig.scale += 0.1;
          });
        }),
        button("缩放-", onPressed: () {
          setState(() {
            _kchartConfig.scale -= 0.1;
          });
        }),
        button("趋势线[${getOpenOrClose(_kchartConfig.isLine)}]", onPressed: () {
          setState(() {
            _kchartConfig.isLine = !_kchartConfig.isLine;
          });
        }),
        button("reload", onPressed: () {
          reloadKLineData();
        }),
        button("update", onPressed: () {
          HFTradeOHLCItem? lastRecord;
          if (_originData.isNotEmpty) {
            lastRecord = _originData.last;
            var lastItem = generateUpdateItemFromLast(lastRecord);

            var dataList = updateKlineData(_originData, [lastItem]);
            count = dataList.length;
            _kchartData = transformData(dataList);
            refresh();
          }
        }),
        button("addData", onPressed: () {
          HFTradeOHLCItem? lastRecord;
          if (_originData.isNotEmpty) {
            lastRecord = _originData.last;
            var lastItem = generateNewItemFromLast(lastRecord); // 生成假日期

            var dataList = updateKlineData(_originData, [lastRecord, lastItem]);
            count = dataList.length;
            _kchartData = transformData(dataList);
            refresh();
          }
        }),
        button("autoplay[${getOpenOrClose(_isAutoRefreshing)}]", onPressed: () {
          if (_isAutoRefreshing) {
            return;
          }
          if (_originData.isNotEmpty) {
            asyncDelay(3000, () {
              bool add = Random().nextInt(2) % 2 == 1 ? true : false;
              autoRefreshData(add);
            }, times: 8);
          }
        }),
      ],
    );
  }

  Widget button(String text, {VoidCallback? onPressed}) {
    return TextButton(
        onPressed: () {
          if (onPressed != null) {
            onPressed();
            setState(() {});
          }
        },
        style: TextButton.styleFrom(backgroundColor: Colors.blue),
        child: Text(text, style: const TextStyle(color: Colors.black)));
  }

  refresh() {
    setState(() {});
  }

  /// 加载本地K线数据并展示
  reloadKLineData() {
    rootBundle.loadString('assets/kline.json').then((result) {
      final parseJson = json.decode(result);
      List<HFTradeOHLCItem> values = [];
      if (parseJson is List) {
        List kLines = parseJson;
        for (var value in kLines) {
          Map item = value;
          HFTradeOHLCItem d = HFTradeOHLCItem();
          d.date = item['day'];
          d.open = double.parse(item['open']);
          d.high = double.parse(item['high']);
          d.low = double.parse(item['low']);
          d.close = double.parse(item['close']);
          d.volume = double.parse(item['volume']);
          d.money = d.volume * (d.close - d.open).abs();
          values.add(d);
        }
      }

      if (values.isNotEmpty) {
        _originData = values;
        count = _originData.length;

        setState(() {
          showLoading = false;
          _kchartData = transformData(values);
        });
      }
    });
  }

  /// 数据转化
  transformData(List<HFTradeOHLCItem> items) {
    int len = items.length;
    if (len == 0) {
      return [];
    }
    List<HFKLineEntry> values = [];
    List indexValues = [];
    var avgStep = [5, 10, 20];
    Map<int, double> maSum = {
      0: 0,
      1: 0,
      2: 0,
    };
    HFKLineEntry prePointData;
    for (var index = 0; index < len; index++) {
      HFTradeOHLCItem item = items[index];
      var pointData = item.transformToKlineEntry();
      values.add(pointData);

      // avg line
      var ma = 0.0;
      var fIndexValues = [0.0, 0.0, 0.0];
      for (var pIndex = 0; pIndex < avgStep.length; pIndex++) {
        var param = avgStep[pIndex];
        maSum[pIndex] = pointData.close.toDouble() + maSum[pIndex]!.toDouble();
        if (index < param - 1) {
          ma = HF_INVALID_VALUE.toDouble();
        } else if (index == param - 1) {
          ma = (maSum[pIndex]! / param);
        } else {
          prePointData = values[index - param];
          maSum[pIndex] = (maSum[pIndex]! - prePointData.close);
          ma = (maSum[pIndex]! / param);
        }
        fIndexValues[pIndex] = ma.toDouble();
      }
      indexValues.add(fIndexValues);
    }

    List<HFPointEntry> values_5 = [];
    List<HFPointEntry> values_10 = [];
    List<HFPointEntry> values_20 = [];
    for (var index = 0; index < indexValues.length; index++) {
      var element = indexValues[index];
      values_5.add(HFPointEntry.xy(index, element[0]));
      values_10.add(HFPointEntry.xy(index, element[1]));
      values_20.add(HFPointEntry.xy(index, element[2]));
    }
    // print(values_10);
    var dataSet = HFChartDataSet(values, HF_QUOTE_KLINE_LABEL);
    var dataSet_5 = HFLineChartDataSet(values_5, HF_QUOTE_TIMELINE_LABEL);
    dataSet_5.lineWidth = 1;
    dataSet_5.lineColor = Colors.blue;
    var dataSet_10 = HFLineChartDataSet(values_10, HF_QUOTE_TIMELINE_LABEL);
    dataSet_10.lineWidth = 1;
    dataSet_10.lineColor = Colors.red;
    var dataSet_20 = HFLineChartDataSet(values_20, HF_QUOTE_TIMELINE_LABEL);
    dataSet_20.lineWidth = 1;
    dataSet_20.lineColor = Colors.orange;
    var newData = HFChartData([dataSet, dataSet_5, dataSet_10, dataSet_20]);
    return newData;
  }

  /// 将新增数据更新到原数据列表
  List<HFTradeOHLCItem> updateKlineData(
      List<HFTradeOHLCItem> items, List<HFTradeOHLCItem> income,
      {type = 0}) {
    if (items.isEmpty) {
      items.addAll(income);
      return items;
    }
    // 依据date来匹配
    var tail = items.last;
    switch (type) {
      case 0:
        // append tail
        int idx = 0;
        for (var value in income) {
          if (value.date == tail.date) {
            break;
          }
          idx++;
        }
        if (idx < income.length) {
          // 查询有值相等，进行替换和追加
          items.removeLast(); // 替换
          items.addAll(income.sublist(idx));
        }
        break;
      case 1:
      // TODO: append head. 拉取历史更多场景。
      default:
    }
    return items;
  }

  /// 自动进行随机更新或新增
  autoRefreshData(bool add) {
    HFTradeOHLCItem lastRecord;
    if (_originData.isNotEmpty) {
      lastRecord = _originData.last;
    } else {
      return;
    }
    if (add) {
      var lastItem = generateNewItemFromLast(lastRecord);

      var dataList = updateKlineData(_originData, [lastRecord, lastItem]);
      count = dataList.length;
      _kchartData = transformData(dataList);
      refresh();
    } else {
      var lastItem = generateUpdateItemFromLast(lastRecord);

      var dataList = updateKlineData(_originData, [lastItem]);
      count = dataList.length;
      _kchartData = transformData(dataList);
      refresh();
    }
  }

  /// 正在自动刷新中。避免重复
  bool _isAutoRefreshing = false;

  /// 异步多次执行block
  Future<void> asyncDelay(int durationInMilliseconds, Function block,
      {times = 1}) async {
    // print('asyncDelay start');
    _isAutoRefreshing = true;
    int idx = 0;
    while (true) {
      await Future.delayed(Duration(milliseconds: durationInMilliseconds));
      // 执行其他异步操作
      block();
      idx++;
      if (idx >= times) break;
    }
    // print('asyncDelay end');
    _isAutoRefreshing = false;
  }

  /// 生成更新item
  HFTradeOHLCItem generateUpdateItemFromLast(HFTradeOHLCItem item) {
    var lastItem = item.copy();
    int seed = 1;
    int add = Random().nextInt(2) % 2 == 1 ? -1 : 1;
    double randomValue = Random().nextDouble() * seed * add;
    var close = double.parse((lastItem.close + randomValue).toStringAsFixed(2));
    lastItem.close = close;
    lastItem.high = max(close, lastItem.high);
    lastItem.low = min(close, lastItem.low);

    return lastItem;
  }

  /// 生成新一条item
  HFTradeOHLCItem generateNewItemFromLast(HFTradeOHLCItem item) {
    var lastItem = item.copy();
    int seed = 1;
    int add = Random().nextInt(2) % 2 == 1 ? -1 : 1;
    double randomValue = Random().nextDouble() * seed * add;
    var close = double.parse((lastItem.close + randomValue).toStringAsFixed(2));
    lastItem.close = close;
    lastItem.high = max(close, lastItem.high);
    lastItem.low = min(close, lastItem.low);
    lastItem.date += Random().nextInt(1000).toString(); // 生成假日期

    return lastItem;
  }
}
