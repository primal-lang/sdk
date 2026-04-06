import 'dart:io';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/platform/base/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/base/platform_web.dart';
import 'package:primal/compiler/runtime/term.dart';

class DirectoryList extends NativeFunctionTerm {
  const DirectoryList()
    : super(
        name: 'directory.list',
        parameters: const [
          Parameter.directory('a'),
        ],
      );

  @override
  Term term(List<Term> arguments) => TermWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );
}

class TermWithArguments extends NativeFunctionTermWithArguments {
  const TermWithArguments({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Term reduce() {
    final Term a = arguments[0].reduce();

    if (a is DirectoryTerm) {
      final List<FileSystemEntity> children = PlatformInterface().directory
          .list(a.value);
      final List<Term> list = [];

      for (final FileSystemEntity child in children) {
        if (child is File) {
          list.add(FileTerm(child));
        } else if (child is Directory) {
          list.add(DirectoryTerm(child));
        }
      }

      return ListTerm(list);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
