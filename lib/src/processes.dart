import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

class ExecResult {
  final int exitCode;
  final String stderr;
  final String stdout;

  const ExecResult._({
    @required this.exitCode,
    @required this.stderr,
    @required this.stdout,
  });
}

/// Runs a command in a shell.
/// Returns a [ExecResult] once the process has terminated.
/// **MUST be awaited.**
///
/// By default, the ouput is printed on the console and logged.
/// Set [silent] to true to avoid that.
///
/// Use [environment] to set the environment variables for the process.
/// If not set the environment of the parent process is inherited.
/// Currently, only US-ASCII environment variables are supported
/// and errors are likely to occur if an environment variable with code-points
/// outside the US-ASCII range is passed in.
Future<ExecResult> exec(
  String executable,
  List<String> arguments, {
  String workDir,
  bool silent = false,
  Map<String, String> environment,
}) async {
  final streamsToFree = <Future<dynamic>>[];
  final freeStreams = () async => Future.wait<dynamic>(streamsToFree);
  try {
    final process = await Process.start(
      executable,
      arguments,
      runInShell: true,
      workingDirectory: workDir,
      environment: environment,
    );
    final errStream = process.stderr.asBroadcastStream();
    final outStream = process.stdout.asBroadcastStream();
    if (!silent) {
      streamsToFree
        ..add(stderr.addStream(errStream))
        ..add(stdout.addStream(outStream));
    }
    final outputStderr = errStream.transform(utf8.decoder).toList();
    final outputStdout = outStream.transform(utf8.decoder).toList();
    final exitCode = await process.exitCode;
    await freeStreams();
    return ExecResult._(
      exitCode: exitCode,
      stdout: (await outputStdout)?.join(),
      stderr: (await outputStderr)?.join(),
    );
  } catch (e) {
    await freeStreams();
    rethrow;
  }
}
