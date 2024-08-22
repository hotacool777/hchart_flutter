import 'package:flutter/material.dart';

import '../../Data/HFChartDataEntry.dart';
import '../../Model/HFGraphicFoundation.dart';
import '_HFTecNodeVolume.dart';
import '../../Canvas/HFCanvasExtension.dart';

/// 成交额指标
class HFTecNodeAmount extends HFTecNodeVolume {
  HFTecNodeAmount(Canvas canvas) : super(canvas);

  @override
  void renderInfoBar(HFRect inRect, Canvas canvas) {
//print('renderInfoBar1' + this.focusIndex.toString());
    if (kline_data.isEmpty) {
      return;
    }
    var focusIndex =
        this.focusIndex == -1 ? kline_data.length - 1 : this.focusIndex;
    if (focusIndex < kline_data.length) {
      var itemData = kline_data[focusIndex];
      if (itemData is HFKLineEntry) {
        // K 线
        HFKLineEntry klineData = itemData;
        var text = 'AMOUNT: ${rectValueFor(itemData)}';

        Paint paint = Paint()..style = PaintingStyle.stroke;
        TextStyle textStyle = const TextStyle(
            color: Colors.black, backgroundColor: Colors.white, fontSize: 10);
        canvas.drawText(
            paint,
            " $text ",
            Offset(inRect.left.toDouble(),
                inRect.top.toDouble() + (infoBarHeight - 10 - 4)),
            textStyle: textStyle,
            drawOrigin: 0);
      }
    }
  }

  @override
  num rectValueFor(HFChartDataEntry item) {
    if (item is HFTimeLineEntry) {
      return item.money;
    } else if (item is HFKLineEntry) {
      return item.money;
    }
    return 0.0;
  }
}
