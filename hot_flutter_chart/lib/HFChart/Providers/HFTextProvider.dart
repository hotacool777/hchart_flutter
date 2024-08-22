import '../Model/HFChartModel.dart';
import '../Model/HFGraphicFoundation.dart';
import 'HFProvider.dart';

abstract class HFTextProvider extends HFProvider {
  List<HFTextModel> textDataInRect(HFRect rect);
}