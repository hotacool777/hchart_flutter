import 'dart:math';

import 'package:flutter/material.dart';

import '../Canvas/HFCanvasPanel.dart';
import '../Configs/HFChartConfig.dart';
import '../Data/HFChartData.dart';
import '../Data/HFChartDataEntry.dart';
import '../Data/HFChartDataSet.dart';
import '../Model/HFGraphicFoundation.dart';
import '../Nodes/HFFlashPointNode.dart';
import '../Nodes/HFFocusNode.dart';
import '../Nodes/HFKLineNode.dart';
import '../Nodes/Tec/HFTecNode.dart';

const int HF_KLINE_VISUAL_COUNT = 20;
const double HF_Line_SCALE = 0.3;

// >> 回调闭包设计
/// tap up 回调：detail、点击的指标类型（未点击到则为 none）、index
typedef HFChartGestureTapUpCallback = void Function(
    TapUpDetails details, HFIndicatorType type, int index);

// <<

class HFKLineView extends StatefulWidget {
  /// 初始化是 data 必须有值，否则 offset 无法默认滑倒最右边
  final HFChartData data;
  final HFChartConfig config;

  final HFChartGestureTapUpCallback? onTapUp;

  // HFKLineView(this.data);
  HFKLineView({required this.data, required this.config, this.onTapUp});

  @override
  State<HFKLineView> createState() => _HFKLineViewState();
}

class _HFKLineViewState extends State<HFKLineView>
    with TickerProviderStateMixin {
  // page UI properties
  int _xAxisCnt = 5;
  int _yAxisCnt = 5;
  double _scale = 1; // 记录缩放scale
  double _indicatorHeight = 100.0; // 副图指标高度
  Size _canvasSize = Size.zero; // 实际canvas size
  Size _renderObjectSize = Size
      .zero; // KLine view的渲染范围，取自context.findRenderObject()?.paintBounds.size

  Offset? _nowKlinePoint;

  List<HFIndicatorType> _indicators = [];
  List<HFTecNode> _tecNodeArr = [];

  double _scaleStart = 1; // 每次缩放起始scale
  double _scrollContentWidth = 500;
  final ScrollController _scrollController = ScrollController();

  int _startIndex = 0;
  int _endIndex = 0;
  int _dataCnt = 0;
  int _visualCnt = 0;
  double _stepWidth = 0;

  HFKLineNode? _node;
  int _zoomIndexStart = 0;
  int _zoomIndexEnd = 0;

  // 1、定义一个叫做“aState”的StateSetter类型方法；
  StateSetter? aState;

  // 闪烁点动画
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    // Firstly, 同步 config 到页面配置
    setupConfig(widget.config);

    // 设置闪烁点动画
    _controller = AnimationController(
        duration: const Duration(milliseconds: 850), vsync: this);
    _animation = Tween(begin: 0.9, end: 0.1).animate(_controller)
      ..addListener(() => setState(() {}));

    // 计算属性处理
    _visualCnt = calculateVisualCnt(_scale);

    // 监听 scrollview
    _scrollController.addListener(scrollControllerListener);
    // scroll 从右开始，起始时需滑到最后侧
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Size? size = context.findRenderObject()?.paintBounds.size;
      _renderObjectSize = size!;
      updateContentWidth();

      var width = size.width;
      //初始化 data 必须有值，否则 offset 无法默认滑倒最右边
      var offset = _scrollContentWidth - width;
      _scrollController.jumpTo(offset);
    });
    super.initState();
  }

  void setupConfig(HFChartConfig? config) {
    // print('setupConfig');
    if (config != null) {
      _scale = config.scale;
      _indicatorHeight = config.indicatorHeight;
      _indicators = config.indicators;
      if (config.axisConfig != null) {
        _xAxisCnt = config.axisConfig!.xAxisCnt;
        _yAxisCnt = config.axisConfig!.yAxisCnt;
      }
    }
  }

  // update scrollview content size
  void updateContentWidth() {
    Size? size = _renderObjectSize;
    var width = size.width;
    HFChartData data = widget.data;
    var klineDataset = data.getDataSetWithLabel(HF_QUOTE_KLINE_LABEL);
    if (klineDataset != null) {
      _dataCnt = klineDataset.values.length;
      _stepWidth = width / _visualCnt;
    }
    if (_dataCnt == 0) {
      return;
    }
    _scrollContentWidth = _stepWidth * _dataCnt;
  }

  /// 柱图高度
  double mainNodeHeight(Size size) {
    _indicatorHeight = widget.config.indicatorHeight;
    var height = size.height - _indicatorHeight * _indicators.length;
    return height;
  }

  @override
  void didUpdateWidget(covariant HFKLineView oldWidget) {
    setupConfig(widget.config); // 更新config
    bool isTail = false; // 是否已在最右
    if (_dataCnt == _endIndex + 1) {
      isTail = true;
    }
    updateContentWidth(); // 数据变化，更新scrollview 范围
    updateScale(widget.config.scale); // 更新scale
    if (isTail) {
      // 最右，新增场景，update index
      double offset = _scrollController.offset;
      Size? size = _renderObjectSize;
      var width = size.width;
      offset = _scrollContentWidth - width;
      var map = calculateStartIndex(offset, _visualCnt, _dataCnt, _stepWidth);
      var start = map['start']!;
      var end = map['end']!;
      _startIndex = start;
      _endIndex = end;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // auxiliaryPanel.dispose();
    _controller.dispose();
    super.dispose();
  }

  // 计算显示范围起始点
  Map<String, int> calculateStartIndex(
      double offset, int visualCnt, int actualCnt, double stepWidth) {
    // print('offset: $offset, visualcnt: $visualCnt, actualcnt: $actualCnt, stepwidth: $stepWidth');
    if (stepWidth <= 0) {
      return {'start': 0, 'end': 0};
    }
    int m = (offset / stepWidth).ceil(); // 向上取整
    int ts = m >= 0 ? m : 0;
    int te = (m + visualCnt) <= actualCnt ? (m + visualCnt) : visualCnt;
    if (m <= 0) {
      //滑到最左边，左边已无更多历史数据，模拟scroll bounce左边显示空白
      ts = 0;
      te = m + visualCnt - 1;
    } else {
      if (m >= actualCnt - visualCnt) {
        //滑到最右边，右边已无更多最新数据，模拟scroll bounce右边显示空白
        te = actualCnt - 1;
        if (m > te - visualCnt) {
          // 滑到最右时，禁止右侧出现空白
          m = max(te - visualCnt + 1, 0);
        }
        ts = m;
      } else {
        ts = m;
        te = m + visualCnt - 1;
      }
    }
    // print('ts: $ts, end: $te');
    return {'start': ts, 'end': te};
  }

  int calculateVisualCnt(double scale) {
    if (scale == 1) {
      // scale 为 1 对应为 default visual count
      return HF_KLINE_VISUAL_COUNT;
    }
    int visualCnt = HF_KLINE_VISUAL_COUNT ~/ scale;
    // print('calculateVisualCnt: ' + visualCnt.toString());
    return visualCnt;
  }

  // scroll滑动位移监听
  scrollControllerListener([bool isForceRender = false]) {
    // print('scrollControllerListener _scrollContentWidth: ' +
    //     _scrollContentWidth.toString());
    // 计算start/end
    double offset = _scrollController.offset;
    var map = calculateStartIndex(offset, _visualCnt, _dataCnt, _stepWidth);
    var start = map['start']!;
    var end = map['end']!;
    setState(() {
      _startIndex = start;
      _endIndex = end;
    });
  }

  // 事件响应处理方法
  void reactForTapTecNode(TapUpDetails details) {
    //print('>> reactForTapTecNode');
    HFTecNode? tecNode;
    int index = 0;
    for (var value in _tecNodeArr) {
      tecNode = value.hitTestWith(
          HFPoint(details.localPosition.dx, details.localPosition.dy));
      if (tecNode != null) {
        break;
      }
      index++;
    }
    if (tecNode != null) {
      HFIndicatorType nextType = switchToNextIndicator(
          tecNode.tecType, widget.config.exchangeIndicators);
      if (nextType != HFIndicatorType.none &&
          index < widget.config.indicators.length) {
        setState(() {
          widget.config.indicators[index] = nextType;
        });
      }
    }

    widget.onTapUp?.call(details,
        tecNode == null ? HFIndicatorType.none : tecNode.tecType, index);
  }

  HFIndicatorType switchToNextIndicator(
      HFIndicatorType current, List<HFIndicatorType> typeList) {
    HFIndicatorType nextType = HFIndicatorType.none;
    int idx = 0;
    for (var value in typeList) {
      idx++;
      if (value == current) {
        if (idx < typeList.length) {
          nextType = typeList[idx];
        } else {
          nextType = typeList[0];
        }
        break;
      }
    }
    return nextType;
  }

  var latestPriceLineLabelOrigin = HFPoint.ZERO_POINT;
  double latestPrice = 0;
  double _latestLineLabelWidth = 90.0;
  double _latestLineLabelHeight = 20.0;

  /// 更新现价线label
  updateLatestLineLabel(HFPoint point, num price) {
    if (point.isValid() || !point.isZero()) {
      latestPriceLineLabelOrigin = HFPoint(
          _canvasSize.width - _latestLineLabelWidth,
          point.y - _latestLineLabelHeight / 2);
      latestPrice = price.toDouble();
    } else {}
  }

  /// 更新scale
  updateScale(double scale) {
    _scale = min(max(scale, widget.config.scaleMin), widget.config.scaleMax); // 框定scale范围
    widget.config.scale = _scale; // 需更新config中scale，否则didupdatewidget会重置
    var newCnt = calculateVisualCnt(_scale);
    if (_visualCnt != newCnt) {
      _visualCnt = newCnt;
      scrollControllerListener();
    }
  }

  /// 将数值转化为坐标点y值，value = (dataIndexInAll, dataValue)
  Offset transferToCoordinate(Offset value) {
    // print('value: ' + value.toString());
    if (_node == null) return Offset.zero;
    int indexInAll = value.dx.toInt();
    int index = indexInAll - _node!.startIndex;
    double x = _node!
        .xPointInRect(index, _node!.pointRect)
        .toDouble(); // 根据主图获取对应index的x坐标。可超界。
    double y = _node!
        .calculatorY(value.dy.toDouble(), _node!.minValue.toDouble(),
            _node!.maxValue.toDouble(), _node!.pointRect)
        .toDouble(); // 计算y坐标。
    //print('transferToCoordinate: ' + Offset(x, y).toString());
    return Offset(x, y);
  }

  /// 将坐标点y值转化为数值
  Offset transferToValue(Offset coordinate) {
    if (_node == null) return Offset.zero;
    var index = _node!.indexAtChartForPoint(
        HFPoint(coordinate.dx, coordinate.dy)); // 根据主图获取在可视范围内的index。
    var indexInAll = index + _node!.startIndex; // 转化为全量index。
    HFKLineEntry value =
        _node!.dataAtChartForIndex(index) as HFKLineEntry; // 获取index对应data
    // print('value: ' + value.close.toString());
    // print('origin value: ' + coordinate.toString());
    // print('new value: ' +
    //     Offset(indexInAll.toDouble(), value.close.toDouble()).toString());
    return Offset(indexInAll.toDouble(), value.close.toDouble());
  }

  var _startFocalPoint = Offset.zero;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      // update renderSize.
      _renderObjectSize = Size(constraints.maxWidth, constraints.maxHeight);
      Size size = _renderObjectSize;
      // 主图高度
      var mainNodeHeight = this.mainNodeHeight(size);
      mainNodeHeight = mainNodeHeight < 0 ? 0 : mainNodeHeight;
      // 区间统计块位置
      return MouseRegion(
          onExit: (event) {
            // print('>> onExit');
            setState(() {
              _nowKlinePoint = null;
            });
          },
          onHover: (event) {
            // print('>> onHover');
            if (event.localPosition >= const Offset(0, 0)) {
              setState(() {
                _nowKlinePoint = event.localPosition;
              });
            }
          },
          child: GestureDetector(
            onTapDown: (TapDownDetails details) {},
            onTapUp: (details) {
              // print('>> onTapUp');
              reactForTapTecNode(details);
            },
            onScaleStart: (details) {
              // print("onScaleStart");
              _scaleStart = _scale;
              _startFocalPoint = details.focalPoint;
              // print('>> onScaleStart: _scaleStart ' + _scaleStart.toString());
            },
            onScaleUpdate: (event) {
              // print("onScaleUpdate");
              // 同时支持拉伸缩放和鼠标上下滑动缩放
              // print('>> onScaleUpdate: ' + event.toString());
              double scale = _scaleStart * event.scale;
              // print('>> onScaleUpdate: event.scale ' + event.scale.toString());
              // 判断是拉伸缩放还是鼠标上下滑动
              if ((event.scale - 1).abs() < 0.001) {
                // event.scale为1，表示非拉伸缩放，进行上下滑动缩放处理
                var gapFocalPoint = event.focalPoint - _startFocalPoint;
                scale = _scaleStart + gapFocalPoint.dy * 0.01;
              }
              // print('>> onScaleUpdate: scale ' + scale.toString());
              updateScale(scale);
            },
            onScaleEnd: (details) {},
            onLongPressDown: (event) {
//print('>> onLongPressDown');
            },
            onLongPress: () {},
            onLongPressCancel: () {},
            onLongPressEnd: (event) {
              setState(() {
                _nowKlinePoint = null;
              });
            },
            onLongPressMoveUpdate: (event) {
              if (event.localPosition >= const Offset(0, 0)) {
                if (event.localPosition.dy <= _canvasSize.height) {
                  setState(() {
                    _nowKlinePoint = event.localPosition;
                  });
                } else {
                  setState(() {
                    _nowKlinePoint = null;
                  });
                }
              }
            },
            onLongPressUp: () {},
            child: Stack(
              children: [
                Container(
                  color: widget.config.backgroundColor, // 背景色
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                        child: HFCanvasPanel((canvas, size) {
//print('>> HFCanvasPanel redraw rect' + size.toString());
                      Rect clipRect =
                          Rect.fromLTWH(0, 0, size.width, size.height);
                      // 先进行裁剪，只在size范围内绘制
                      canvas.clipRect(Offset.zero & clipRect.size);

                      _canvasSize = size;
                      // 主图rect
                      HFRect mainRect =
                          HFRect(0, 0, size.width, mainNodeHeight);
                      HFKLineNode node = HFKLineNode(canvas,
                          latestPriceLineUpdate: (HFPoint point, num price) {
                        updateLatestLineLabel(point, price);
                      });
                      // scale小于一定值时，显示趋势线
                      node.isLine = _scale <= HF_Line_SCALE ? true : false;
                      // config 设置为趋势线时，强制显示趋势线
                      node.isLine = widget.config.isLine ? true : node.isLine;
                      node.isLatestPriceLineShow =
                          widget.config.isLatestPriceLineShow;
                      node.xAxisCnt = _xAxisCnt;
                      node.yAxisCnt = _yAxisCnt;
                      node.visualCnt = _visualCnt;
                      node.pointRect = mainRect;
                      if (_startIndex == 0 && _endIndex == 0) {
                        // 初始显示范围
                        _startIndex = 0;
                        _endIndex = _startIndex + HF_KLINE_VISUAL_COUNT - 1;
                      }
                      node.startIndex = _startIndex;
                      node.endIndex = _endIndex;
                      node.data = widget.data;
                      node.setNeedsDisplay();
                      _node = node;

                      // update node params
                      _scrollContentWidth = node.contentWidth();
                      _stepWidth = node.stepWidth.toDouble();
                      _dataCnt = node.maxPointCnt.toInt();

                      int focusIndex = -1;
                      var realPoint = HFPoint.ZERO_POINT;
                      var focusPoint = HFPoint.ZERO_POINT;
                      HFChartDataEntry? itemData;
                      final nowKlinePoint = _nowKlinePoint;
                      if (nowKlinePoint != null) {
                        realPoint = HFPoint(
                            nowKlinePoint.dx, nowKlinePoint.dy); // 实际点击的点
                        focusIndex = node
                            .indexAtChartForPoint(realPoint); // 单屏图中数据的 index
                        focusPoint = node.pointAtChartForIndex(
                            focusIndex); // 转化为实际数据对应的坐标点（单屏）
                        focusIndex = focusIndex +
                            node.startIndex; // scrollview 中 index，需加上 startIndex
                        itemData = node.dataAtChartForIndex(focusIndex);
                      }

                      // tec
                      List<HFTecNode> tecNodes = [];
                      for (var index = 0; index < _indicators.length; index++) {
                        HFTecNode tecNode = HFTecNode(canvas);
                        tecNode.tecType = _indicators[index];
                        tecNode.visualCnt = _visualCnt;
                        tecNode.pointRect = HFRect(
                            0,
                            mainRect.height + _indicatorHeight * index,
                            size.width,
                            _indicatorHeight);
                        tecNode.startIndex = node.startIndex;
                        tecNode.endIndex = node.endIndex;
                        tecNode.data = widget.data;
                        tecNode.focusIndex = focusIndex;
                        tecNode.setNeedsDisplay();
                        tecNodes.add(tecNode);
                      }
                      _tecNodeArr = tecNodes;

                      // flash point
                      if (true || node.isLine) {
                        // TODO: 闪烁点显示逻辑。可考虑单独图层刷新
                        HFFlashPointNode flashNode = HFFlashPointNode(canvas);
                        flashNode.controller = _controller;
                        flashNode.opacity = _animation.value;
                        flashNode.flashPoint = focusPoint;
                        flashNode.setNeedsDisplay();
                      }

                      // focus
                      // TODO: 可考虑单独图层刷新
                      if (!widget.config.isZoomStatisticsShow) {
                        // 区间统计显示时，不显示查价线
                        if (focusIndex >= 0) {
                          HFFocusNode focusNode = HFFocusNode(canvas);
                          focusNode.pointRect =
                              HFRect(0, 0, size.width, size.height);
                          focusNode.itemData = itemData;
                          focusNode.focusPoint = focusPoint; // 单屏显示点
                          focusNode.setNeedsDisplay();
                        }
                      }
                    }, Size(constraints.maxWidth, constraints.maxHeight)))
                  ],
                ),
                Visibility(
                  visible: true,
                  child: Positioned.fill(
                      child: SingleChildScrollView(
                          // reverse: true,
                          physics:
                              // auxiliaryPanel.isDrawing()
                              //     ? NeverScrollableScrollPhysics() :
                              const BouncingScrollPhysics(), // 注：通过禁止滚动来解决pan手势冲突。
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController,
                          child: Container(
                            width: _scrollContentWidth,
                          ))),
                ),
                Visibility(
                    visible: widget.config.isLatestPriceLineShow,
                    child: Positioned(
                      top: latestPriceLineLabelOrigin.y.toDouble(),
                      left: latestPriceLineLabelOrigin.x.toDouble() - 100,
                      child: GestureDetector(
                        child: Container(
                          width: _latestLineLabelWidth, // 宽
                          height: _latestLineLabelHeight, // 高
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: Colors.white, // 背景色
                            border: Border.all(
                                color: const Color(0xFFFF0000),
                                width: 0.5), // border
                            borderRadius: BorderRadius.circular((8)), // 圆角
                          ),
                          child: Row(
                            children: [
                              const Spacer(),
                              Text(
                                latestPrice.toStringAsFixed(2),
                                style: const TextStyle(color: Colors.red),
                              ),
                              Container(
                                alignment: Alignment.centerRight,
                                child: const Icon(
                                  Icons.arrow_right,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Size? size = _renderObjectSize;
                          var width = size.width;
                          var offset = _scrollContentWidth - width;
                          // print('offset: $offset');
                          _scrollController.animateTo(offset,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.ease);
                        },
                      ),
                    )),
                Visibility(
                    visible: widget.config.isZoomStatisticsShow,
                    child: Positioned(
                        top: 10,
                        left: 10,
                        child: StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          aState = setState;
                          return Text(
                            "起:$_zoomIndexStart 终:$_zoomIndexEnd",
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          );
                        }))),
              ],
            ),
          ));
    });
  }
}
