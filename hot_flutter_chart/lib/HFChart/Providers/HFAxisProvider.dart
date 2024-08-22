import '../Model/HFGraphicFoundation.dart';
import 'HFProvider.dart';

abstract class HFAxisProvider extends HFProvider {
  List axisDataInRect(HFRect rect);
  List xAxisDataInRect(HFRect rect);
  List yAxisDataInRect(HFRect rect);
}
