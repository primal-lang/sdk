import 'dart:io';

import 'package:primal/utils/console.dart';

/// The installer the website documents, and the one that put this binary in
/// place.
const String installerUrl = 'https://primal-lang.org/install.sh';

const String updateFlag = '--update';
const String uninstallFlag = '--uninstall';

/// Whether [arguments] asks for this installation to be updated or removed.
///
/// Both flags act on the executable rather than on a program, so they are
/// answered before the compiler is involved at all.
bool isSelfInstallRequest(List<String> arguments) =>
    arguments.contains(updateFlag) || arguments.contains(uninstallFlag);

/// Updates or removes this installation by running the published installer.
///
/// Release lookup, PATH handling and platform support live in the installer and
/// not here: deferring to it keeps a single implementation of all three, and
/// means a fix to it reaches users who are still running an old binary. It is
/// pointed at the directory this executable resolves to, so an installation
/// made with `--install-dir` is updated and removed where it actually is.
///
/// Returns the installer's own exit code, `1` when it could not be run at all,
/// and `2` when the invocation was wrong.
Future<int> runSelfInstall(
  List<String> arguments, {
  Console? console,
  String Function()? resolveExecutable,
  Future<List<int>> Function(String url)? downloadScript,
  Future<int> Function(String executable, List<String> arguments)? runCommand,
  Directory Function()? createWorkingDirectory,
}) async {
  final Console currentConsole = console ?? Console();
  final bool uninstall = arguments.contains(uninstallFlag);
  final String flag = uninstall ? uninstallFlag : updateFlag;

  // Either flag replaces or deletes the whole installation, so there is nothing
  // left for the same run to also be doing. Anything alongside it is a wrong
  // invocation rather than a request to be interpreted.
  if (arguments.length != 1) {
    currentConsole.error(
      'Error: $flag cannot be combined with other arguments.',
    );

    return 2;
  }

  final String executable = (resolveExecutable ?? _resolveExecutable)();
  final String executableName = executable.split(Platform.pathSeparator).last;

  // Under 'dart run' the executable this resolves to is the Dart VM, so the
  // installer would be aimed at the Dart SDK's own bin directory and would
  // install Primal into it. Only a compiled binary can replace itself.
  if (executableName == 'dart' || executableName == 'dart.exe') {
    currentConsole.error(
      "Error: $flag works from an installed Primal binary, not from 'dart run'.",
    );

    return 2;
  }

  final String installDirectory = File(executable).parent.path;
  final List<int> installer;

  try {
    installer = await (downloadScript ?? _downloadScript)(installerUrl);
  } catch (error) {
    currentConsole.error(
      'Error: could not fetch the installer from $installerUrl ($error)',
    );

    return 1;
  }

  // Left null until the directory exists, so the cleanup below can tell a run
  // that never got one apart from a run that did.
  Directory? workingDirectory;

  try {
    workingDirectory = (createWorkingDirectory ?? _createWorkingDirectory)();

    final File script = File(
      '${workingDirectory.path}${Platform.pathSeparator}install.sh',
    );

    // Written to a file and handed to bash rather than piped into it: a
    // download that was cut short midway would otherwise be run as far as it
    // got, leaving the installation in whatever state half a script produces.
    script.writeAsBytesSync(installer);

    return await (runCommand ?? _runCommand)('bash', <String>[
      shellPath(script.path),
      '--install-dir',
      shellPath(installDirectory),
      if (uninstall) uninstallFlag,
    ]);
  } on ProcessException {
    // Reported rather than left to surface as an unhandled exception: without a
    // shell to run it in there is nothing the installer could have done here,
    // and the way out is a manual reinstall.
    currentConsole.error(
      'Error: $flag needs bash to run the installer, and it could not be '
      'started. Reinstall from https://primal-lang.org/start instead.',
    );

    return 1;
  } on FileSystemException catch (error) {
    // Staging the downloaded script is the only part of this that writes to the
    // local disk, so an unusable temporary directory surfaces here: an unset or
    // read-only TMPDIR, a full filesystem, a sandbox policy. Left unhandled it
    // would escape through the asynchronous main and exit 255 with a stack
    // trace, instead of the 1 this function promises.
    currentConsole.error(
      'Error: $flag could not write the installer to a temporary file '
      '($error). Reinstall from https://primal-lang.org/start instead.',
    );

    return 1;
  } finally {
    workingDirectory?.deleteSync(recursive: true);
  }
}

/// [path] in the form the shell running the installer reads it.
///
/// A Windows path does not survive the trip to bash: the command line it is
/// handed on is parsed with the backslashes separating its components taken as
/// escape characters, so 'C:\Users\me\install.sh' arrives as
/// 'C:Usersmeinstall.sh' and names nothing. The same file written the way that
/// shell names it, '/c/Users/me/install.sh', leaves nothing in the path for
/// that parse to consume.
///
/// It is also the form the installer already works in, which matters for the
/// install directory as much as for the script. Run from a shell the installer
/// takes that directory from HOME and writes the string into the PATH entry it
/// adds; naming the same directory the Windows way would leave an update adding
/// a second entry alongside the first and an uninstall unable to find either.
///
/// Only a drive-letter path is rewritten, and nothing but a Windows path is
/// one, so what every other platform resolves its executable to is returned
/// untouched.
String shellPath(String path) {
  if (!RegExp(r'^[A-Za-z]:[\\/]').hasMatch(path)) {
    return path;
  }

  return '/${path[0].toLowerCase()}${path.substring(2).replaceAll(r'\', '/')}';
}

String _resolveExecutable() => Platform.resolvedExecutable;

Directory _createWorkingDirectory() =>
    Directory.systemTemp.createTempSync('primal_installer_');

Future<List<int>> _downloadScript(String url) async {
  final HttpClient client = HttpClient();

  // The proxy variables curl reads are honoured here too. Without them a
  // machine that can only reach the network through a proxy would fail to fetch
  // the very script that then downloads the release through curl successfully.
  client.findProxy = HttpClient.findProxyFromEnvironment;

  try {
    final Uri uri = Uri.parse(url);
    final HttpClientRequest request = await client.getUrl(uri);
    final HttpClientResponse response = await request.close();

    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('HTTP ${response.statusCode}', uri: uri);
    }

    final List<int> bytes = <int>[];

    await for (final List<int> chunk in response) {
      bytes.addAll(chunk);
    }

    return bytes;
  } finally {
    client.close();
  }
}

/// Runs [executable] wired to this process's own stdio, so that the installer
/// draws its progress on the terminal as it goes instead of having its output
/// captured and replayed once it has already finished.
Future<int> _runCommand(String executable, List<String> arguments) async {
  final Process process = await Process.start(
    executable,
    arguments,
    mode: ProcessStartMode.inheritStdio,
  );

  return process.exitCode;
}
