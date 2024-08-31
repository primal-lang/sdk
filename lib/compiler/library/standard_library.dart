import 'package:primal/compiler/library/arithmetic/num_abs.dart';
import 'package:primal/compiler/library/arithmetic/num_add.dart';
import 'package:primal/compiler/library/arithmetic/num_as_degrees.dart';
import 'package:primal/compiler/library/arithmetic/num_as_radians.dart';
import 'package:primal/compiler/library/arithmetic/num_ceil.dart';
import 'package:primal/compiler/library/arithmetic/num_clamp.dart';
import 'package:primal/compiler/library/arithmetic/num_cos.dart';
import 'package:primal/compiler/library/arithmetic/num_dec.dart';
import 'package:primal/compiler/library/arithmetic/num_div.dart';
import 'package:primal/compiler/library/arithmetic/num_floor.dart';
import 'package:primal/compiler/library/arithmetic/num_fraction.dart';
import 'package:primal/compiler/library/arithmetic/num_inc.dart';
import 'package:primal/compiler/library/arithmetic/num_infinity.dart';
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
import 'package:primal/compiler/library/control/if.dart';
import 'package:primal/compiler/library/control/try.dart';
import 'package:primal/compiler/library/debug/debug.dart';
import 'package:primal/compiler/library/error/throw.dart';
import 'package:primal/compiler/library/index/element_at.dart';
import 'package:primal/compiler/library/list/list_concat.dart';
import 'package:primal/compiler/library/list/list_contains.dart';
import 'package:primal/compiler/library/list/list_drop.dart';
import 'package:primal/compiler/library/list/list_filled.dart';
import 'package:primal/compiler/library/list/list_first.dart';
import 'package:primal/compiler/library/list/list_get.dart';
import 'package:primal/compiler/library/list/list_index_of.dart';
import 'package:primal/compiler/library/list/list_init.dart';
import 'package:primal/compiler/library/list/list_insert_end.dart';
import 'package:primal/compiler/library/list/list_insert_start.dart';
import 'package:primal/compiler/library/list/list_is_empty.dart';
import 'package:primal/compiler/library/list/list_is_not_empty.dart';
import 'package:primal/compiler/library/list/list_join.dart';
import 'package:primal/compiler/library/list/list_last.dart';
import 'package:primal/compiler/library/list/list_length.dart';
import 'package:primal/compiler/library/list/list_remove.dart';
import 'package:primal/compiler/library/list/list_remove_at.dart';
import 'package:primal/compiler/library/list/list_reverse.dart';
import 'package:primal/compiler/library/list/list_set.dart';
import 'package:primal/compiler/library/list/list_sublist.dart';
import 'package:primal/compiler/library/list/list_swap.dart';
import 'package:primal/compiler/library/list/list_tail.dart';
import 'package:primal/compiler/library/list/list_take.dart';
import 'package:primal/compiler/library/logic/bool_and.dart';
import 'package:primal/compiler/library/logic/bool_not.dart';
import 'package:primal/compiler/library/logic/bool_or.dart';
import 'package:primal/compiler/library/logic/bool_xor.dart';
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
import 'package:primal/compiler/library/string/str_at.dart';
import 'package:primal/compiler/library/string/str_concat.dart';
import 'package:primal/compiler/library/string/str_contains.dart';
import 'package:primal/compiler/library/string/str_drop.dart';
import 'package:primal/compiler/library/string/str_ends_with.dart';
import 'package:primal/compiler/library/string/str_first.dart';
import 'package:primal/compiler/library/string/str_init.dart';
import 'package:primal/compiler/library/string/str_is_empty.dart';
import 'package:primal/compiler/library/string/str_is_not_empty.dart';
import 'package:primal/compiler/library/string/str_last.dart';
import 'package:primal/compiler/library/string/str_length.dart';
import 'package:primal/compiler/library/string/str_lowercase.dart';
import 'package:primal/compiler/library/string/str_match.dart';
import 'package:primal/compiler/library/string/str_remove_at.dart';
import 'package:primal/compiler/library/string/str_replace.dart';
import 'package:primal/compiler/library/string/str_reverse.dart';
import 'package:primal/compiler/library/string/str_starts_with.dart';
import 'package:primal/compiler/library/string/str_substring.dart';
import 'package:primal/compiler/library/string/str_tail.dart';
import 'package:primal/compiler/library/string/str_take.dart';
import 'package:primal/compiler/library/string/str_trim.dart';
import 'package:primal/compiler/library/string/str_uppercase.dart';
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
        NumAsRadians(),
        NumAsDegrees(),
        NumInfinity(),
        NumFraction(),
        NumClamp(),

        // Logic
        BoolAnd(),
        BoolOr(),
        BoolXor(),
        BoolNot(),

        // Index
        ElementAt(),

        // String
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
        StrRemoveAt(),
        StrReverse(),

        // List
        ListInsertStart(),
        ListInsertEnd(),
        ListAt(),
        ListSet(),
        ListJoin(),
        ListLength(),
        ListConcat(),
        ListIsEmpty(),
        ListIsNotEmpty(),
        ListContains(),
        ListFirst(),
        ListLast(),
        ListInit(),
        ListTail(),
        ListTake(),
        ListDrop(),
        ListRemove(),
        ListRemoveAt(),
        ListReverse(),
        ListFilled(),
        ListIndexOf(),
        ListSwap(),
        ListSublist(),

        // Casting
        IsNumber(),
        IsInteger(),
        IsDecimal(),
        IsInfinite(),
        IsString(),
        IsBoolean(),
        IsList(),
        ToNumber(),
        ToInteger(),
        ToDecimal(),
        ToString(),
        ToBoolean(),
      ];
}
