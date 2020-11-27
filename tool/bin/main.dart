//import 'dart:convert';
import 'dart:io';

import 'package:github_actions_toolkit/github_actions_toolkit.dart' as gaction;

/*
extension on String {
  List<String> get lines {
    const ls = LineSplitter();
    return ls.convert(this);
  }
}
*/

void unawaited(Future future) {}

void main() async {
  exitCode = 0;
  const logger = gaction.log;

  // Outputs

  final time = DateTime.now().toString();
  gaction.setOutput('time', time);
  gaction.addPath('/doesntexist');
  gaction.setEnvironmentVariable('TEST_ENV', 'Testvalue');

  // Subprocesses

  logger.startGroup('Echo tests');

  final message = 'This is an awaited echo test';
  unawaited(gaction.execInParallel('sleep', ['5']).then(
    (value) => logger.info('Parallel exec has terminated'),
  ));
  unawaited(gaction.exec('echo', ['This is an unawaited echo test']).then(
    (value) => logger.info('Unawaited echo test has terminated'),
  ));
  final process = await Process.start('sleep', ['5']);
  unawaited(stderr.addStream(process.stderr));
  final echoTest = await gaction.exec('echo', [message]);
  logger.info('Awaited echo test:'
      '\n* stdout: [${echoTest.stdout}]'
      '\n* stderr: [${echoTest.stderr}]');

  logger.endGroup();

  if (!echoTest.stdout.startsWith(message)) {
    throw AssertionError('Echo test failed');
  }
}
