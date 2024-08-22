import 'package:flutter/material.dart';

import '../Canvas/HFCanvasPanel.dart';
import '../Model/HFGraphicFoundation.dart';
import '../Nodes/HFAxisNode.dart';

class HFChartView extends StatefulWidget {
  HFChartView();

  @override
  State<HFChartView> createState() => _HFChartViewState();
}

class _HFChartViewState extends State<HFChartView> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: const Alignment(0.6, 0.6),
      children: [
        HFCanvasPanel((canvas, size) {
          HFAxisNode node = HFAxisNode(canvas);
          node.actualCnt = 1;
          node.data = null;
          node.pointRect = HFRect(0, 0, size.width, size.height);
          node.setNeedsDisplay();
          // print('object {$canvas}, {$size}');
        }, const Size(100, 400)),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$_counter'),
            TextButton(
              onPressed: () => setState(() {
                _counter++;
              }),
              child: const Text('+1'),
            ),
            const Text('11'),
          ],
        )
      ],
    );
  }
}
