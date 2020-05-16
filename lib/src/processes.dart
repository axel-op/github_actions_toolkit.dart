import 'dart:convert';
import 'dart:io';

import 'package:synchronized/synchronized.dart';

extension<K, V> on Map<K, V> {
  Map<K, V> unmodifiableCopy() => Map<K, V>.unmodifiable(this);
}

extension<T> on List<T> {
  List<T> unmodifiableCopy() => List<T>.unmodifiable(this);
}

final _lock = Lock();

/// Runs a command in a shell.
/// Returns a [ProcessResult] once the process has terminated.
///
/// Processes executed by this command are queued,
/// and they cannot run in parallel (to preserve consistence in logs).
/// A process will not start until the previous ones have terminated.
/// Use [execInParallel] to run a process in parallel.
///
/// By default, the outputs will be printed on the console.
/// If [silent] is true, nothing will be printed
/// but the outputs will still be available in [ProcessResult].
///
/// Use [workingDirectory] to set the working directory for the process.
/// Note that the change of directory occurs before executing the process on some platforms,
/// which may have impact when using relative paths for the executable and the arguments.
///
/// Use [environment] to set the environment variables for the process.
/// If not set the environment of the parent process is inherited.
/// Currently, only US-ASCII environment variables are supported
/// and errors are likely to occur if an environment variable with code-points
/// outside the US-ASCII range is passed in.
Future<ProcessResult> exec(
  String executable,
  List<String> arguments, {
  String workingDirectory,
  bool silent = false,
  Map<String, String> environment,
}) async {
  return _lock.synchronized(
    () => _exec(
      executable,
      arguments.unmodifiableCopy(),
      workingDirectory,
      silent ?? false,
      environment?.unmodifiableCopy(),
    ),
  );
}

/// Runs a command in a shell,
/// without waiting for other processes.
/// Returns a [ProcessResult] once the process has terminated.
///
/// Processes run by this command are executed immediately.
/// Nothing will be printed on the console,
/// but the outputs will still be available in [ProcessResult].
///
/// Use [workingDirectory] to set the working directory for the process.
/// Note that the change of directory occurs before executing the process on some platforms,
/// which may have impact when using relative paths for the executable and the arguments.
///
/// Use [environment] to set the environment variables for the process.
/// If not set the environment of the parent process is inherited.
/// Currently, only US-ASCII environment variables are supported
/// and errors are likely to occur if an environment variable with code-points
/// outside the US-ASCII range is passed in.
Future<ProcessResult> execInParallel(
  String executable,
  List<String> arguments, {
  String workingDirectory,
  Map<String, String> environment,
}) async {
  return _exec(
    executable,
    arguments.unmodifiableCopy(),
    workingDirectory,
    true,
    environment?.unmodifiableCopy(),
  );
}

Future<ProcessResult> _exec(
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
  return ProcessResult(
    process.pid,
    exitCode,
    (await outputStdout)?.join(),
    (await outputStderr)?.join(),
  );
}
