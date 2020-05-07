import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

class ProcessResult {
  final int exitCode;
  final String stderr;
  final String stdout;

  const ProcessResult({
    @required this.exitCode,
    @required this.stderr,
    @required this.stdout,
  });
}

/// Runs a command in a shell.
/// Returns a [ProcessResult] once the process has terminated.
Future<ProcessResult> runCommand(
  String executable,
  List<String> arguments,
) async {
  final streamsToFree = <Future<dynamic>>[];
  final freeStreams = () async => Future.wait<dynamic>(streamsToFree);
  try {
    final process = await Process.start(
      executable,
      arguments,
      runInShell: true,
    );
    final errStream = process.stderr.asBroadcastStream();
    final outStream = process.stdout.asBroadcastStream();
    streamsToFree
      ..add(stderr.addStream(errStream))
      ..add(stdout.addStream(outStream));
    final outputStderr = errStream.transform(utf8.decoder).toList();
    final outputStdout = outStream.transform(utf8.decoder).toList();
    final exitCode = await process.exitCode;
    await freeStreams();
    return ProcessResult(
      exitCode: exitCode,
      stdout: (await outputStdout)?.join(),
      stderr: (await outputStderr)?.join(),
    );
  } catch (e) {
    await freeStreams();
    rethrow;
  }
}
