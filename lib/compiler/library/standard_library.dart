import 'package:primal/compiler/library/booleans/and.dart';
import 'package:primal/compiler/library/booleans/not.dart';
import 'package:primal/compiler/library/booleans/or.dart';
import 'package:primal/compiler/library/booleans/xor.dart';
import 'package:primal/compiler/library/casting/is_boolean.dart';
import 'package:primal/compiler/library/casting/is_decimal.dart';
import 'package:primal/compiler/library/casting/is_infinite.dart';
import 'package:primal/compiler/library/casting/is_integer.dart';
import 'package:primal/compiler/library/casting/is_number.dart';
import 'package:primal/compiler/library/casting/is_string.dart';
import 'package:primal/compiler/library/casting/to_boolean.dart';
import 'package:primal/compiler/library/casting/to_decimal.dart';
import 'package:primal/compiler/library/casting/to_integer.dart';
import 'package:primal/compiler/library/casting/to_number.dart';
import 'package:primal/compiler/library/casting/to_string.dart';
import 'package:primal/compiler/library/comparison/eq.dart';
import 'package:primal/compiler/library/comparison/neq.dart';
import 'package:primal/compiler/library/control/if.dart';
import 'package:primal/compiler/library/control/try.dart';
import 'package:primal/compiler/library/debug/debug.dart';
import 'package:primal/compiler/library/error/throw.dart';
import 'package:primal/compiler/library/generic/at.dart';
import 'package:primal/compiler/library/generic/concat.dart';
import 'package:primal/compiler/library/generic/contains.dart';
import 'package:primal/compiler/library/generic/drop.dart';
import 'package:primal/compiler/library/generic/first.dart';
import 'package:primal/compiler/library/generic/init.dart';
import 'package:primal/compiler/library/generic/is_empty.dart';
import 'package:primal/compiler/library/generic/is_not_empty.dart';
import 'package:primal/compiler/library/generic/last.dart';
import 'package:primal/compiler/library/generic/length.dart';
import 'package:primal/compiler/library/generic/remove.dart';
import 'package:primal/compiler/library/generic/reverse.dart';
import 'package:primal/compiler/library/generic/tail.dart';
import 'package:primal/compiler/library/generic/take.dart';
import 'package:primal/compiler/library/numbers/abs.dart';
import 'package:primal/compiler/library/numbers/ceil.dart';
import 'package:primal/compiler/library/numbers/cos.dart';
import 'package:primal/compiler/library/numbers/dec.dart';
import 'package:primal/compiler/library/numbers/div.dart';
import 'package:primal/compiler/library/numbers/floor.dart';
import 'package:primal/compiler/library/numbers/ge.dart';
import 'package:primal/compiler/library/numbers/gt.dart';
import 'package:primal/compiler/library/numbers/inc.dart';
import 'package:primal/compiler/library/numbers/is_even.dart';
import 'package:primal/compiler/library/numbers/is_negative.dart';
import 'package:primal/compiler/library/numbers/is_odd.dart';
import 'package:primal/compiler/library/numbers/is_positive.dart';
import 'package:primal/compiler/library/numbers/is_zero.dart';
import 'package:primal/compiler/library/numbers/le.dart';
import 'package:primal/compiler/library/numbers/log.dart';
import 'package:primal/compiler/library/numbers/lt.dart';
import 'package:primal/compiler/library/numbers/max.dart';
import 'package:primal/compiler/library/numbers/min.dart';
import 'package:primal/compiler/library/numbers/mod.dart';
import 'package:primal/compiler/library/numbers/mul.dart';
import 'package:primal/compiler/library/numbers/pow.dart';
import 'package:primal/compiler/library/numbers/round.dart';
import 'package:primal/compiler/library/numbers/sin.dart';
import 'package:primal/compiler/library/numbers/sqrt.dart';
import 'package:primal/compiler/library/numbers/sub.dart';
import 'package:primal/compiler/library/numbers/sum.dart';
import 'package:primal/compiler/library/numbers/tan.dart';
import 'package:primal/compiler/library/strings/ends_with.dart';
import 'package:primal/compiler/library/strings/lowercase.dart';
import 'package:primal/compiler/library/strings/match.dart';
import 'package:primal/compiler/library/strings/replace.dart';
import 'package:primal/compiler/library/strings/starts_with.dart';
import 'package:primal/compiler/library/strings/substring.dart';
import 'package:primal/compiler/library/strings/trim.dart';
import 'package:primal/compiler/library/strings/uppercase.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class StandardLibrary {
  static List<FunctionPrototype> get() => [
        // Generic
        Eq(),
        Neq(),

        // Control
        If(),
        Try(),

        // Error
        Throw(),

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

        // Strings
        Substring(),
        StartsWith(),
        EndsWith(),
        Replace(),
        Uppercase(),
        Lowercase(),
        Trim(),
        Match(),

        // Generic
        Length(),
        Concat(),
        First(),
        Last(),
        Init(),
        Tail(),
        At(),
        IsEmpty(),
        IsNotEmpty(),
        Contains(),
        Take(),
        Drop(),
        Remove(),
        Reverse(),

        // Casting
        ToNumber(),
        ToInteger(),
        ToDecimal(),
        ToString(),
        ToBoolean(),
        IsNumber(),
        IsInteger(),
        IsDecimal(),
        IsInfinite(),
        IsString(),
        IsBoolean(),
      ];
}
