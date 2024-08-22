import '../Model/HFGraphicFoundation.dart';
import 'HFProvider.dart';

abstract class HFLineProvider extends HFProvider {
  List lineDataInRect(HFRect rect);
}
