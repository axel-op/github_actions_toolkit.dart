import 'dart:convert';
import 'dart:io';

import 'package:github_actions_toolkit/github_actions_toolkit.dart' as gaction;

extension on String {
  List<String> get lines {
    const ls = LineSplitter();
    return ls.convert(this);
  }
}

void main() async {
  exitCode = 0;

  // Logging

  const logger = gaction.log;
  logger
    ..info('This is just a message')
    ..warning('This is a warning message')
    ..error('This is an error message');
  if (gaction.isDebug) logger.debug('This is a debug message');

  // Inputs

  const inputWhoToGreet = gaction.Input(
    'who-to-greet',
    isRequired: false,
    canBeEmpty: true,
  );
  logger.info('Hello ${inputWhoToGreet.value ?? 'World'}!');

  // Outputs

  final time = DateTime.now().toString();
  gaction.setOutput('time', time);

  // Environment

  final eventPayload =
      jsonDecode(gaction.env.eventPayload) as Map<String, dynamic>;
  if (eventPayload.containsKey('pull_request')) {
    logger.info('This pull request has been ${eventPayload['action']}');
  }

  // Subprocesses

  logger.startGroup('Echo test');
  final message = 'This is an echo test';
  final echoTest = gaction.exec('echo', [message]);
  logger.endGroup();

  if (!echoTest.stdout.startsWith(message)) {
    throw AssertionError('Echo test failed');
  }

  final analyzerResult = await logger.group(
    'Executing dartanalyzer',
    () async => gaction.exec(
      'dartanalyzer',
      [gaction.env.workspace.path, '--format', 'machine'],
    ),
  );

  if (analyzerResult.exitCode != 0) {
    logger.error('Execution of dartanalyzer has failed');
    exit(analyzerResult.exitCode);
  }

  var errorCount = 0;
  for (final line in analyzerResult.stdout.lines) {
    if (line.split('|')[0] == 'ERROR') errorCount += 1;
  }
  if (errorCount > 0) logger.warning('$errorCount have been found!');
}
