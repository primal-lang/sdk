import 'package:purified/compiler/library/booleans/and.dart';
import 'package:purified/compiler/library/booleans/not.dart';
import 'package:purified/compiler/library/booleans/or.dart';
import 'package:purified/compiler/library/booleans/xor.dart';
import 'package:purified/compiler/library/casting/is_boolean.dart';
import 'package:purified/compiler/library/casting/is_decimal.dart';
import 'package:purified/compiler/library/casting/is_integer.dart';
import 'package:purified/compiler/library/casting/is_number.dart';
import 'package:purified/compiler/library/casting/is_string.dart';
import 'package:purified/compiler/library/casting/to_boolean.dart';
import 'package:purified/compiler/library/casting/to_decimal.dart';
import 'package:purified/compiler/library/casting/to_integer.dart';
import 'package:purified/compiler/library/casting/to_number.dart';
import 'package:purified/compiler/library/casting/to_string.dart';
import 'package:purified/compiler/library/control/if.dart';
import 'package:purified/compiler/library/control/try.dart';
import 'package:purified/compiler/library/debug/debug.dart';
import 'package:purified/compiler/library/error/error.dart';
import 'package:purified/compiler/library/generic/eq.dart';
import 'package:purified/compiler/library/generic/neq.dart';
import 'package:purified/compiler/library/numbers/abs.dart';
import 'package:purified/compiler/library/numbers/ceil.dart';
import 'package:purified/compiler/library/numbers/cos.dart';
import 'package:purified/compiler/library/numbers/dec.dart';
import 'package:purified/compiler/library/numbers/div.dart';
import 'package:purified/compiler/library/numbers/floor.dart';
import 'package:purified/compiler/library/numbers/ge.dart';
import 'package:purified/compiler/library/numbers/gt.dart';
import 'package:purified/compiler/library/numbers/inc.dart';
import 'package:purified/compiler/library/numbers/is_even.dart';
import 'package:purified/compiler/library/numbers/is_negative.dart';
import 'package:purified/compiler/library/numbers/is_odd.dart';
import 'package:purified/compiler/library/numbers/is_positive.dart';
import 'package:purified/compiler/library/numbers/is_zero.dart';
import 'package:purified/compiler/library/numbers/le.dart';
import 'package:purified/compiler/library/numbers/log.dart';
import 'package:purified/compiler/library/numbers/lt.dart';
import 'package:purified/compiler/library/numbers/max.dart';
import 'package:purified/compiler/library/numbers/min.dart';
import 'package:purified/compiler/library/numbers/mod.dart';
import 'package:purified/compiler/library/numbers/mul.dart';
import 'package:purified/compiler/library/numbers/pow.dart';
import 'package:purified/compiler/library/numbers/round.dart';
import 'package:purified/compiler/library/numbers/sin.dart';
import 'package:purified/compiler/library/numbers/sqrt.dart';
import 'package:purified/compiler/library/numbers/sub.dart';
import 'package:purified/compiler/library/numbers/sum.dart';
import 'package:purified/compiler/library/numbers/tan.dart';
import 'package:purified/compiler/semantic/function_prototype.dart';

class StandardLibrary {
  static List<FunctionPrototype> get() => [
        // Generic
        Eq(),
        Neq(),

        // Control
        If(),
        Try(),

        // Error
        Error(),

        // Debug
        Debug(),

        // Numbers
        Abs(),
        Inc(),
        Dec(),
        Sum(),
        Sub(),
        Mul(),
        Div(),
        Mod(),
        Min(),
        Max(),
        Pow(),
        Sqrt(),
        Round(),
        Floor(),
        Ceil(),
        Sin(),
        Cos(),
        Tan(),
        Log(),
        Gt(),
        Lt(),
        Ge(),
        Le(),
        IsNegative(),
        IsPositive(),
        IsZero(),
        IsEven(),
        IsOdd(),

        // Booleans
        And(),
        Or(),
        Xor(),
        Not(),

        // Casting
        ToNumber(),
        ToInteger(),
        ToDecimal(),
        ToString(),
        ToBoolean(),
        IsNumber(),
        IsInteger(),
        IsDecimal(),
        IsString(),
        IsBoolean(),
      ];
}
