import '../Model/HFGraphicFoundation.dart';

abstract class HFProvider {
  int get xAxisCnt;
  set xAxisCnt(int value);

  int get yAxisCnt;
  set yAxisCnt(int value);

  HFRect get pointRect;
  set pointRect(HFRect value);

  int get actualCnt;
  set actualCnt(int value);

  int get visualCnt;
  set visualCnt(int value);

  int get startIndex;
  set startIndex(int value);

  int get endIndex;
  set endIndex(int value);

  void calculateLimitValue();
  num calculatorX(num forValue, num min, num max, HFRect inRect);
  num calculatorY(num forValue, num min, num max, HFRect inRect);
  double contentWidth();
}
