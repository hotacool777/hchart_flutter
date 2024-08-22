import '../Model/HFGraphicFoundation.dart';
import 'HFProvider.dart';

abstract class HFFocusProvider extends HFProvider {
  List focusDataInRect(HFRect rect);
}
