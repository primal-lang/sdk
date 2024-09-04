import 'package:primal/compiler/library/arithmetic/num_abs.dart';
import 'package:primal/compiler/library/arithmetic/num_add.dart';
import 'package:primal/compiler/library/arithmetic/num_as_degrees.dart';
import 'package:primal/compiler/library/arithmetic/num_as_radians.dart';
import 'package:primal/compiler/library/arithmetic/num_ceil.dart';
import 'package:primal/compiler/library/arithmetic/num_clamp.dart';
import 'package:primal/compiler/library/arithmetic/num_cos.dart';
import 'package:primal/compiler/library/arithmetic/num_dec.dart';
import 'package:primal/compiler/library/arithmetic/num_decimal_random.dart';
import 'package:primal/compiler/library/arithmetic/num_div.dart';
import 'package:primal/compiler/library/arithmetic/num_floor.dart';
import 'package:primal/compiler/library/arithmetic/num_fraction.dart';
import 'package:primal/compiler/library/arithmetic/num_inc.dart';
import 'package:primal/compiler/library/arithmetic/num_infinity.dart';
import 'package:primal/compiler/library/arithmetic/num_int_random.dart';
import 'package:primal/compiler/library/arithmetic/num_is_even.dart';
import 'package:primal/compiler/library/arithmetic/num_is_negative.dart';
import 'package:primal/compiler/library/arithmetic/num_is_odd.dart';
import 'package:primal/compiler/library/arithmetic/num_is_positive.dart';
import 'package:primal/compiler/library/arithmetic/num_is_zero.dart';
import 'package:primal/compiler/library/arithmetic/num_log.dart';
import 'package:primal/compiler/library/arithmetic/num_max.dart';
import 'package:primal/compiler/library/arithmetic/num_min.dart';
import 'package:primal/compiler/library/arithmetic/num_mod.dart';
import 'package:primal/compiler/library/arithmetic/num_mul.dart';
import 'package:primal/compiler/library/arithmetic/num_negative.dart';
import 'package:primal/compiler/library/arithmetic/num_pow.dart';
import 'package:primal/compiler/library/arithmetic/num_round.dart';
import 'package:primal/compiler/library/arithmetic/num_sign.dart';
import 'package:primal/compiler/library/arithmetic/num_sin.dart';
import 'package:primal/compiler/library/arithmetic/num_sqrt.dart';
import 'package:primal/compiler/library/arithmetic/num_sub.dart';
import 'package:primal/compiler/library/arithmetic/num_sum.dart';
import 'package:primal/compiler/library/arithmetic/num_tan.dart';
import 'package:primal/compiler/library/casting/is_boolean.dart';
import 'package:primal/compiler/library/casting/is_decimal.dart';
import 'package:primal/compiler/library/casting/is_infinite.dart';
import 'package:primal/compiler/library/casting/is_integer.dart';
import 'package:primal/compiler/library/casting/is_list.dart';
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
import 'package:primal/compiler/library/console/console_write.dart';
import 'package:primal/compiler/library/console/console_write_ln.dart';
import 'package:primal/compiler/library/control/if.dart';
import 'package:primal/compiler/library/control/try.dart';
import 'package:primal/compiler/library/error/throw.dart';
import 'package:primal/compiler/library/index/element_at.dart';
import 'package:primal/compiler/library/list/list_at.dart';
import 'package:primal/compiler/library/list/list_concat.dart';
import 'package:primal/compiler/library/list/list_contains.dart';
import 'package:primal/compiler/library/list/list_drop.dart';
import 'package:primal/compiler/library/list/list_filled.dart';
import 'package:primal/compiler/library/operators/operator_add.dart';
import 'package:primal/compiler/library/operators/operator_div.dart';
import 'package:primal/compiler/library/operators/operator_eq.dart';
import 'package:primal/compiler/library/operators/operator_ge.dart';
import 'package:primal/compiler/library/operators/operator_gt.dart';
import 'package:primal/compiler/library/operators/operator_le.dart';
import 'package:primal/compiler/library/operators/operator_lt.dart';
import 'package:primal/compiler/library/operators/operator_mod.dart';
import 'package:primal/compiler/library/operators/operator_mul.dart';
import 'package:primal/compiler/library/operators/operator_neq.dart';
import 'package:primal/compiler/library/operators/operator_sub.dart';
import 'package:primal/compiler/runtime/node.dart';

class StandardLibrary {
  static List<FunctionNode> get() => [
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
        //OperatorAnd(),
        //OperatorOr(),
        //OperatorNot(),

        // Control
        If(),
        Try(),

        // Error
        Throw(),

        // Comparison
        CompEq(),
        CompNeq(),
        CompGt(),
        CompGe(),
        CompLt(),
        CompLe(),

        // Arithmetic
        NumAbs(),
        NumAdd(),
        NumAsDegrees(),
        NumAsRadians(),
        NumCeil(),
        NumClamp(),
        NumCos(),
        NumDec(),
        NumDecimalRandom(),
        NumDiv(),
        NumFloor(),
        NumFraction(),
        NumInc(),
        NumInfinity(),
        NumIntegerRandom(),
        NumIsEven(),
        NumIsNegative(),
        NumIsOdd(),
        NumIsPositive(),
        NumIsZero(),
        NumLog(),
        NumMax(),
        NumMin(),
        NumMod(),
        NumMul(),
        NumNegative(),
        NumPow(),
        NumRound(),
        NumSign(),
        NumSin(),
        NumSqrt(),
        NumSub(),
        NumSum(),
        NumTan(),

        // Logic
        //BoolAnd(),
        //BoolOr(),
        //BoolXor(),
        //BoolNot(),

        // Index
        ElementAt(),

        // String
        /*StrSubstring(),
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
        StrRemoveAt(),
        StrReverse(),
        StrBytes(),
        StrIndexOf(),
        StrPadLeft(),
        StrPadRight(),
        StrSplit(),*/

        // List
        ListAt(),
        ListConcat(),
        ListContains(),
        ListDrop(),
        ListFilled(),
        //ListInsertStart(),
        //ListInsertEnd(),
        //ListSet(),
        //ListJoin(),
        //ListLength(),
        //ListIsEmpty(),
        //ListIsNotEmpty(),
        //ListFirst(),
        //ListLast(),
        //ListInit(),
        //ListTail(),
        //ListTake(),
        //ListRemove(),
        //ListRemoveAt(),
        //ListReverse(),
        //ListIndexOf(),
        //ListSwap(),
        //ListSublist(),

        // Casting
        IsBoolean(),
        IsDecimal(),
        IsInfinite(),
        IsInteger(),
        IsList(),
        IsNumber(),
        IsString(),
        ToBoolean(),
        ToDecimal(),
        ToInteger(),
        ToNumber(),
        ToString(),

        // Console
        ConsoleWrite(),
        ConsoleWriteLn(),
      ];
}
