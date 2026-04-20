import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class TimeFormat extends NativeFunctionTerm {
  const TimeFormat()
    : super(
        name: 'time.format',
        parameters: const [
          Parameter.timestamp('a'),
          Parameter.string('b'),
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
    final Term b = arguments[1].reduce();

    if ((a is TimestampTerm) && (b is StringTerm)) {
      final String formatted = _formatDateTime(a.value, b.value);

      return StringTerm(formatted);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }

  String _formatDateTime(DateTime dateTime, String pattern) {
    final StringBuffer result = StringBuffer();
    int index = 0;
    bool inQuote = false;

    while (index < pattern.length) {
      final String character = pattern[index];

      // Handle single quote for escaping
      if (character == "'") {
        // Check for escaped quote ('')
        if (index + 1 < pattern.length && pattern[index + 1] == "'") {
          result.write("'");
          index += 2;
        } else {
          inQuote = !inQuote;
          index++;
        }
        continue;
      }

      // If inside quotes, treat as literal
      if (inQuote) {
        result.write(character);
        index++;
        continue;
      }

      // Try to match a format token
      final String? token = _matchToken(pattern, index);

      if (token != null) {
        result.write(_formatToken(dateTime, token));
        index += token.length;
      } else {
        result.write(character);
        index++;
      }
    }

    return result.toString();
  }

  String? _matchToken(String pattern, int index) {
    // Order matters: longer tokens must be checked first
    const List<String> tokens = [
      'yyyy',
      'yy',
      'MM',
      'dd',
      'HH',
      'hh',
      'mm',
      'ss',
      'SSS',
      'M',
      'd',
      'H',
      'h',
      'm',
      's',
      'a',
    ];

    for (final String token in tokens) {
      if (pattern.startsWith(token, index)) {
        return token;
      }
    }

    return null;
  }

  String _formatToken(DateTime dateTime, String token) {
    switch (token) {
      case 'yyyy':
        return dateTime.year.toString().padLeft(4, '0');
      case 'yy':
        return (dateTime.year % 100).toString().padLeft(2, '0');
      case 'MM':
        return dateTime.month.toString().padLeft(2, '0');
      case 'M':
        return dateTime.month.toString();
      case 'dd':
        return dateTime.day.toString().padLeft(2, '0');
      case 'd':
        return dateTime.day.toString();
      case 'HH':
        return dateTime.hour.toString().padLeft(2, '0');
      case 'H':
        return dateTime.hour.toString();
      case 'hh':
        return _hour12(dateTime).toString().padLeft(2, '0');
      case 'h':
        return _hour12(dateTime).toString();
      case 'mm':
        return dateTime.minute.toString().padLeft(2, '0');
      case 'm':
        return dateTime.minute.toString();
      case 'ss':
        return dateTime.second.toString().padLeft(2, '0');
      case 's':
        return dateTime.second.toString();
      case 'SSS':
        return dateTime.millisecond.toString().padLeft(3, '0');
      case 'a':
        return dateTime.hour < 12 ? 'AM' : 'PM';
      default:
        return token;
    }
  }

  int _hour12(DateTime dateTime) {
    if (dateTime.hour == 0) {
      return 12;
    } else if (dateTime.hour > 12) {
      return dateTime.hour - 12;
    } else {
      return dateTime.hour;
    }
  }
}
