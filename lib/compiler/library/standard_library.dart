import 'package:primal/compiler/library/booleans/bool_and.dart';
import 'package:primal/compiler/library/booleans/bool_not.dart';
import 'package:primal/compiler/library/booleans/bool_or.dart';
import 'package:primal/compiler/library/booleans/bool_xor.dart';
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
import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/library/comparison/comp_ge.dart';
import 'package:primal/compiler/library/comparison/comp_gt.dart';
import 'package:primal/compiler/library/comparison/comp_le.dart';
import 'package:primal/compiler/library/comparison/comp_lt.dart';
import 'package:primal/compiler/library/comparison/comp_neq.dart';
import 'package:primal/compiler/library/control/if.dart';
import 'package:primal/compiler/library/control/try.dart';
import 'package:primal/compiler/library/debug/debug.dart';
import 'package:primal/compiler/library/error/throw.dart';
import 'package:primal/compiler/library/numbers/num_abs.dart';
import 'package:primal/compiler/library/numbers/num_add.dart';
import 'package:primal/compiler/library/numbers/num_ceil.dart';
import 'package:primal/compiler/library/numbers/num_cos.dart';
import 'package:primal/compiler/library/numbers/num_dec.dart';
import 'package:primal/compiler/library/numbers/num_div.dart';
import 'package:primal/compiler/library/numbers/num_floor.dart';
import 'package:primal/compiler/library/numbers/num_inc.dart';
import 'package:primal/compiler/library/numbers/num_is_even.dart';
import 'package:primal/compiler/library/numbers/num_is_negative.dart';
import 'package:primal/compiler/library/numbers/num_is_odd.dart';
import 'package:primal/compiler/library/numbers/num_is_positive.dart';
import 'package:primal/compiler/library/numbers/num_is_zero.dart';
import 'package:primal/compiler/library/numbers/num_log.dart';
import 'package:primal/compiler/library/numbers/num_max.dart';
import 'package:primal/compiler/library/numbers/num_min.dart';
import 'package:primal/compiler/library/numbers/num_mod.dart';
import 'package:primal/compiler/library/numbers/num_mul.dart';
import 'package:primal/compiler/library/numbers/num_negative.dart';
import 'package:primal/compiler/library/numbers/num_pow.dart';
import 'package:primal/compiler/library/numbers/num_round.dart';
import 'package:primal/compiler/library/numbers/num_sin.dart';
import 'package:primal/compiler/library/numbers/num_sqrt.dart';
import 'package:primal/compiler/library/numbers/num_sub.dart';
import 'package:primal/compiler/library/numbers/num_sum.dart';
import 'package:primal/compiler/library/numbers/num_tan.dart';
import 'package:primal/compiler/library/operators/operator_add.dart';
import 'package:primal/compiler/library/operators/operator_and.dart';
import 'package:primal/compiler/library/operators/operator_div.dart';
import 'package:primal/compiler/library/operators/operator_eq.dart';
import 'package:primal/compiler/library/operators/operator_ge.dart';
import 'package:primal/compiler/library/operators/operator_gt.dart';
import 'package:primal/compiler/library/operators/operator_le.dart';
import 'package:primal/compiler/library/operators/operator_lt.dart';
import 'package:primal/compiler/library/operators/operator_mod.dart';
import 'package:primal/compiler/library/operators/operator_mul.dart';
import 'package:primal/compiler/library/operators/operator_neq.dart';
import 'package:primal/compiler/library/operators/operator_not.dart';
import 'package:primal/compiler/library/operators/operator_or.dart';
import 'package:primal/compiler/library/operators/operator_sub.dart';
import 'package:primal/compiler/library/strings/str_at.dart';
import 'package:primal/compiler/library/strings/str_concat.dart';
import 'package:primal/compiler/library/strings/str_contains.dart';
import 'package:primal/compiler/library/strings/str_drop.dart';
import 'package:primal/compiler/library/strings/str_ends_with.dart';
import 'package:primal/compiler/library/strings/str_first.dart';
import 'package:primal/compiler/library/strings/str_init.dart';
import 'package:primal/compiler/library/strings/str_is_empty.dart';
import 'package:primal/compiler/library/strings/str_is_not_empty.dart';
import 'package:primal/compiler/library/strings/str_last.dart';
import 'package:primal/compiler/library/strings/str_length.dart';
import 'package:primal/compiler/library/strings/str_lowercase.dart';
import 'package:primal/compiler/library/strings/str_match.dart';
import 'package:primal/compiler/library/strings/str_remove.dart';
import 'package:primal/compiler/library/strings/str_replace.dart';
import 'package:primal/compiler/library/strings/str_reverse.dart';
import 'package:primal/compiler/library/strings/str_starts_with.dart';
import 'package:primal/compiler/library/strings/str_substring.dart';
import 'package:primal/compiler/library/strings/str_tail.dart';
import 'package:primal/compiler/library/strings/str_take.dart';
import 'package:primal/compiler/library/strings/str_trim.dart';
import 'package:primal/compiler/library/strings/str_uppercase.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class StandardLibrary {
  static List<FunctionPrototype> get() => [
        // Operators
        OperatorEq(),
        OperatorNeq(),
        OperatorGt(),
        OperatorLt(),
        OperatorGe(),
        OperatorLe(),
        OperatorAdd(),
        OperatorSub(),
        OperatorMul(),
        OperatorDiv(),
        OperatorMod(),
        OperatorAnd(),
        OperatorOr(),
        OperatorNot(),

        // Control
        If(),
        Try(),

        // Error
        Throw(),

        // Debug
        Debug(),

        // Comparison
        CompEq(),
        CompNeq(),
        CompGt(),
        CompGe(),
        CompLt(),
        CompLe(),

        // Arithmetic
        NumAdd(),
        NumSum(),
        NumSub(),
        NumMul(),
        NumDiv(),
        NumMod(),
        NumAbs(),
        NumNegative(),
        NumInc(),
        NumDec(),
        NumMin(),
        NumMax(),
        NumPow(),
        NumSqrt(),
        NumRound(),
        NumFloor(),
        NumCeil(),
        NumSin(),
        NumCos(),
        NumTan(),
        NumLog(),
        NumIsNegative(),
        NumIsPositive(),
        NumIsZero(),
        NumIsEven(),
        NumIsOdd(),

        // Logic
        BoolAnd(),
        BoolOr(),
        BoolXor(),
        BoolNot(),

        // Strings
        StrSubstring(),
        StrStartsWith(),
        StrEndsWith(),
        StrReplace(),
        StrUppercase(),
        StrLowercase(),
        StrTrim(),
        StrMatch(),
        StrLength(),
        StrConcat(),
        StrFirst(),
        StrLast(),
        StrInit(),
        StrTail(),
        StrAt(),
        StrIsEmpty(),
        StrIsNotEmpty(),
        StrContains(),
        StrTake(),
        StrDrop(),
        StrRemove(),
        StrReverse(),

        // Casting
        IsNumber(),
        IsInteger(),
        IsDecimal(),
        IsInfinite(),
        IsString(),
        IsBoolean(),
        ToNumber(),
        ToInteger(),
        ToDecimal(),
        ToString(),
        ToBoolean(),
      ];
}
