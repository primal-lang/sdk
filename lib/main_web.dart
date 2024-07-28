import 'dart:math';
import 'package:js/js.dart';

@JS('mathMinv3')
external set mathMinFunction(Function v);

void main(List<String> args) {
  mathMinFunction = allowInterop(min);
}
