import 'dart:io';

/// A line editor that supports command history navigation with up/down arrow keys.
///
/// This class handles raw terminal input to detect special keys like arrows,
/// backspace, and enter. It maintains an in-memory command history that can be
/// navigated using up/down keys, similar to bash terminal behavior.
class LineEditor {
  final String _prompt;
  final List<String> _history = [];
  int _historyIndex = 0;

  LineEditor({String prompt = ''}) : _prompt = prompt;

  /// Reads a line of input with history navigation support.
  ///
  /// Returns the entered line (trimmed), or empty string on EOF.
  String readLine() {
    if (!stdin.hasTerminal) {
      return stdin.readLineSync()?.trim() ?? '';
    }

    final bool wasLineMode = stdin.lineMode;
    final bool wasEchoMode = stdin.echoMode;

    try {
      stdin.lineMode = false;
      stdin.echoMode = false;

      final String line = _readLineRaw();

      if (line.isNotEmpty) {
        _history.add(line);
      }
      _historyIndex = _history.length;

      return line;
    } finally {
      stdin.lineMode = wasLineMode;
      stdin.echoMode = wasEchoMode;
    }
  }

  String _readLineRaw() {
    final List<int> buffer = [];
    int cursorPosition = 0;
    String savedInput = '';

    while (true) {
      final int byte = stdin.readByteSync();

      if (byte == -1) {
        // EOF
        return buffer.isEmpty ? '' : String.fromCharCodes(buffer).trim();
      }

      if (byte == 10 || byte == 13) {
        // Enter key (LF or CR)
        stdout.writeln();
        return String.fromCharCodes(buffer).trim();
      }

      if (byte == 127 || byte == 8) {
        // Backspace (127 on most terminals, 8 on some)
        if (cursorPosition > 0) {
          buffer.removeAt(cursorPosition - 1);
          cursorPosition--;
          _redrawLine(buffer, cursorPosition);
        }
        continue;
      }

      if (byte == 3) {
        // Ctrl+C
        stdout.writeln('^C');
        exit(0);
      }

      if (byte == 4) {
        // Ctrl+D (EOF)
        if (buffer.isEmpty) {
          stdout.writeln();
          exit(0);
        }
        continue;
      }

      if (byte == 27) {
        // Escape sequence
        final int next = stdin.readByteSync();
        if (next == 91) {
          // CSI sequence (ESC [)
          final int code = stdin.readByteSync();
          switch (code) {
            case 65:
              // Up arrow
              if (_history.isEmpty) {
                continue;
              }
              if (_historyIndex == _history.length) {
                savedInput = String.fromCharCodes(buffer);
              }
              if (_historyIndex > 0) {
                _historyIndex--;
                buffer.clear();
                buffer.addAll(_history[_historyIndex].codeUnits);
                cursorPosition = buffer.length;
                _redrawLine(buffer, cursorPosition);
              }
            case 66:
              // Down arrow
              if (_history.isEmpty) {
                continue;
              }
              if (_historyIndex < _history.length) {
                _historyIndex++;
                buffer.clear();
                if (_historyIndex == _history.length) {
                  buffer.addAll(savedInput.codeUnits);
                } else {
                  buffer.addAll(_history[_historyIndex].codeUnits);
                }
                cursorPosition = buffer.length;
                _redrawLine(buffer, cursorPosition);
              }
            case 67:
              // Right arrow
              if (cursorPosition < buffer.length) {
                cursorPosition++;
                stdout.write('\x1b[C');
              }
            case 68:
              // Left arrow
              if (cursorPosition > 0) {
                cursorPosition--;
                stdout.write('\x1b[D');
              }
            case 51:
              // Possibly Delete key (ESC [ 3 ~)
              final int tilde = stdin.readByteSync();
              if (tilde == 126 && cursorPosition < buffer.length) {
                buffer.removeAt(cursorPosition);
                _redrawLine(buffer, cursorPosition);
              }
            case 72:
              // Home key
              cursorPosition = 0;
              _redrawLine(buffer, cursorPosition);
            case 70:
              // End key
              cursorPosition = buffer.length;
              _redrawLine(buffer, cursorPosition);
          }
        }
        continue;
      }

      if (byte >= 32 && byte < 127) {
        // Printable ASCII character
        buffer.insert(cursorPosition, byte);
        cursorPosition++;
        if (cursorPosition == buffer.length) {
          stdout.writeCharCode(byte);
        } else {
          _redrawLine(buffer, cursorPosition);
        }
      }
    }
  }

  void _redrawLine(List<int> buffer, int cursorPosition) {
    // Move cursor to start of line, clear line, write buffer, reposition cursor
    stdout.write('\r\x1b[K$_prompt${String.fromCharCodes(buffer)}');
    // Move cursor to correct position
    final int moveBack = buffer.length - cursorPosition;
    if (moveBack > 0) {
      stdout.write('\x1b[${moveBack}D');
    }
  }
}
