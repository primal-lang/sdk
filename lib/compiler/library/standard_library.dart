import 'package:dry/compiler/library/condition/if.dart';
import 'package:dry/compiler/library/generic/eq.dart';
import 'package:dry/compiler/library/numbers/add.dart';
import 'package:dry/compiler/library/numbers/gt.dart';
import 'package:dry/compiler/library/numbers/mul.dart';
import 'package:dry/compiler/library/numbers/sub.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';

class StandardLibrary {
  static List<FunctionPrototype> get() => [
        // Generic
        Eq(),

        // Condition
        If(),

        // Numbers
        Add(),
        Sub(),
        Mul(),
        Gt(),
      ];
}
