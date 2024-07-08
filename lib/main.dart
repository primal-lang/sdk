import 'package:dry/compiler.dart';

void main(List<String> args) {
  final Compiler compiler = Compiler.fromFile(args[0]);
  compiler.compile();
}
