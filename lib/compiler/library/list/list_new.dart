import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ListNew extends NativeFunctionPrototype {
  ListNew()
      : super(
          name: 'list.new',
          parameters: [],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    return const ListReducibleValue([]);
  }
}
