import 'package:primal/compiler/errors/generic_error.dart';

class GenericWarning extends GenericError {
  const GenericWarning(String message) : super('Warning', message);
}
