import 'dart:cli';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

extension<K, V> on Map<K, V> {
  Map<K, V> unmodifiableCopy() => Map<K, V>.unmodifiable(this);
}

extension<T> on List<T> {
  List<T> unmodifiableCopy() => List<T>.unmodifiable(this);
}

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
///
/// By default, the outputs will be printed on the console.
/// If [silent] is true, nothing will be printed
/// but the outputs will still be available in [ExecResult].
///
/// Use [environment] to set the environment variables for the process.
/// If not set the environment of the parent process is inherited.
/// Currently, only US-ASCII environment variables are supported
/// and errors are likely to occur if an environment variable with code-points
/// outside the US-ASCII range is passed in.
ExecResult exec(
  String executable,
  List<String> arguments, {
  String workDir,
  bool silent = false,
  Map<String, String> environment,
}) {
  return waitFor<ExecResult>(_exec(
    executable,
    arguments.unmodifiableCopy(),
    workDir,
    silent ?? false,
    environment?.unmodifiableCopy(),
  ));
}

Future<ExecResult> _exec(
  String executable,
  List<String> arguments,
  String workDir,
  bool silent,
  Map<String, String> environment,
) async {
  final process = await Process.start(
    executable,
    arguments,
    runInShell: true,
    workingDirectory: workDir,
    environment: environment,
  );
  final errStream = process.stderr.asBroadcastStream();
  final outStream = process.stdout.asBroadcastStream();
  final outputStderr = errStream.transform(utf8.decoder).toList();
  final outputStdout = outStream.transform(utf8.decoder).toList();
  if (!silent) {
    await Future.wait([
      stderr.addStream(errStream),
      stdout.addStream(outStream),
    ]);
  }
  final exitCode = await process.exitCode;
  return ExecResult._(
    exitCode: exitCode,
    stdout: (await outputStdout)?.join(),
    stderr: (await outputStderr)?.join(),
  );
}
