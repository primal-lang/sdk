import 'package:primal/compiler/library/arithmetic/num_abs.dart';
import 'package:primal/compiler/library/arithmetic/num_add.dart';
import 'package:primal/compiler/library/arithmetic/num_div.dart';
import 'package:primal/compiler/library/arithmetic/num_mod.dart';
import 'package:primal/compiler/library/arithmetic/num_mul.dart';
import 'package:primal/compiler/library/arithmetic/num_sub.dart';
import 'package:primal/compiler/library/arithmetic/num_sum.dart';
import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/library/comparison/comp_ge.dart';
import 'package:primal/compiler/library/comparison/comp_gt.dart';
import 'package:primal/compiler/library/comparison/comp_le.dart';
import 'package:primal/compiler/library/comparison/comp_lt.dart';
import 'package:primal/compiler/library/comparison/comp_neq.dart';
import 'package:primal/compiler/library/control/if.dart';
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
        //OperatorAnd(),
        //OperatorOr(),
        //OperatorNot(),

        // Control
        If(),
        //Try(),

        // Error
        //Throw(),

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
        /*NumNegative(),
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
        NumSign(),
        NumIntegerRandom(),
        NumDecimalRandom(),*/

        // Logic
        /*BoolAnd(),
        BoolOr(),
        BoolXor(),
        BoolNot(),*/

        // Index
        //ElementAt(),

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
        /*ListInsertStart(),
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
        ListSublist(),*/

        // Casting
        /*IsNumber(),
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
        ToBoolean(),*/

        // Console
        //ConsoleWrite(),
        //ConsoleWriteLn(),
      ];
}
