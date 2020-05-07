import 'processes.dart';

void setErrorMessage(String message) => _echo('error', message);
void setWarningMessage(String message) => _echo('warning', message);
void setDebugMessage(String message) => _echo('debug', message);

Future<void> _echo(String command, String message) async {
  await runCommand('echo', ['::$command::$message']);
}
