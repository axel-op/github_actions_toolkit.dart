import 'dart:convert';
import 'dart:io';

import 'package:github_actions_toolkit/github_actions_toolkit.dart' as gaction;

extension on String {
  List<String> get lines {
    const ls = LineSplitter();
    return ls.convert(this);
  }
}

void unawaited(Future future) {}

void main() async {
  exitCode = 0;
  const logger = gaction.log;

  // Outputs

  final time = DateTime.now().toString();
  gaction.setOutput('time', time);

  // Subprocesses

  logger.startGroup('Echo tests');

  final message = 'This is an echo test';
  unawaited(
    gaction.exec('echo', ['This is an unawaited echo test']).then(
      (value) => logger.info('Unawaited echo test has terminated'),
    ),
  );
  final echoTest = await gaction.exec('echo', [message]);
  logger.info('Awaited echo test:'
      '\n* stdout: [${echoTest.stdout}]'
      '\n* stderr: [${echoTest.stderr}]');

  logger.endGroup();

  if (!echoTest.stdout.startsWith(message)) {
    throw AssertionError('Echo test failed');
  }
}
