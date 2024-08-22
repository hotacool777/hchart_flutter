# hot_flutter_chart
本文介绍如何使用flutter版HChart。HChart的flutter版本，项目名称hot_flutter_chart。
可通过以下方式集成到项目直接使用，或进行二次开发。

## Features

- K线图（蜡烛图、线图）
   - 拖动
   - 缩放（桌面端上下滑动事件控制、移动端亦可支持两指操作）
- 副图指标。默认支持（算法可自行调整）：
   - vol
   - macd
   - kdj
- 多副图指标（最大4个）
- 查价线（十字线）
   - 闪烁点
- 现价线，点击滑到最新
- 趋势线（包含阴影）

## Install Chart
待支持。尚未上传到pub.dev，可通过源码集成。
## Manual Download
从github下载源码到本地。

HChart本身以package方式开发。下载到本地后，可在pubspec.yaml中，以相对路径方式依赖，例如：
```yaml
  dependencies:
    # hac flutter chart
    hot_flutter_chart:
      path: ../hot_flutter_chart
```

## Usage
可参考 hf_chart_sample 项目。
### 在布局文件中添加图表组件
参照main.dart，添加图表组件：
```dart
import 'package:hot_flutter_chart/HFChart/hot_flutter_chart.dart';
...
  // 添加K线图组件
Container(
  height: 450,
  margin: const EdgeInsets.symmetric(horizontal: 10),
  child: HFKLineView(
      data: _kchartData, // 设置线图数据
    config: _kchartConfig, // 设置线图UI
  ),
),
...

```
### 线图UI设置
HFChartConfig 为线图UI设置类。对实例对象 _kchartConfig 中属性进行设置。
### 线图数据处理
需对原始股票行情数据进行处理：

- HFChartDataSet 为线图中的绘制单元（线、蜡烛图等）的属性和数据设置类。
- HFChartData 为最终传入线图组件的绘制集合类。

参考 sample ，最终需转化为 HFChart 支持数据格式：
```dart
/// 数据转化
transformData(List<HFTradeOHLCItem> items) {
  ...
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
```
