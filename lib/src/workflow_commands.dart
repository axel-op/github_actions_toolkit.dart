import 'dart:io';

/// Creates or updates an environment variable for any actions running next in a job.
/// 
/// The action that creates or updates the environment variable does not have access to the new value,
/// but all subsequent actions in a job will have access.
/// 
/// Environment variables are case-sensitive and you can include punctuation.
void setEnvironmentVariable(String name, String value) =>
    _echo('set-env', value, {'name': name});

/// Sets an action's output parameter.
///
/// Optionally, you can also declare output parameters in an action's metadata file.
/// For more information,
/// see "[Metadata syntax for GitHub Actions.](https://help.github.com/en/articles/metadata-syntax-for-github-actions#outputs)"
void setOutput(String name, String value) =>
    _echo('set-output', value, {'name': name});

/// Prepends a directory to the system `PATH` variable for all subsequent actions in the current job.
/// The currently running action cannot access the new path variable.
void addPath(String path) => _echo('add-path', path);

/// Creates an error message and prints the message to the log.
///
/// You can optionally provide a filename ([file]), line number ([line]), and column ([column]) number where the warning occurred.
void setErrorMessage(
  String message, {
  String file,
  String line,
  String column,
}) =>
    _echo('error', message, _params(file, line, column));

/// Creates a warning message and prints the message to the log.
///
/// You can optionally provide a filename ([file]), line number ([line]), and column ([column]) number where the warning occurred.
void setWarningMessage(
  String message, {
  String file,
  String line,
  String column,
}) {
  _echo('warning', message, _params(file, line, column));
}

/// Prints a debug message to the log.
///
/// You must create a secret named `ACTIONS_STEP_DEBUG` with the value `true`
/// to see the debug messages set by this command in the log.
/// To learn more about creating secrets and using them in a step,
/// see "[Creating and using encrypted secrets.](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets)"
void setDebugMessage(
  String message, {
  String file,
  String line,
  String column,
}) =>
    _echo('debug', message, _params(file, line, column));

Map<String, String> _params(String file, String line, String column) =>
    [file, line, column].any((e) => e != null)
        ? {'file': file, 'line': line, 'col': column}
        : null;

/// Masking a value prevents a string or variable from being printed in the log.
///
/// Each masked word separated by whitespace is replaced with the `*` character.
/// You can use an environment variable or string for the mask's [value].
void maskValueInLog(String value) => _echo('add-mask', value);

/// You can use this command to create environment variables
/// for sharing with your workflow's `pre:` or `post:` actions.
/// 
/// For example, you can create a file with the `pre:` action,
/// pass the file location to the `main:` action,
/// and then use the `post:` action to delete the file.
/// Alternatively, you could create a file with the `main:` action,
/// pass the file location to the `post:` action,
/// and also use the `post:` action to delete the file.
/// 
/// If you have multiple `pre:` or `post:` actions,
/// you can only access the saved [value] in the action where save-state was used.
/// 
/// For more information on the `post:` action,
/// see "[Metadata syntax for GitHub Actions.](https://help.github.com/en/actions/building-actions/metadata-syntax-for-github-actions#post)".
/// 
/// The saved [value] is not available to YAML files.
/// It is stored as an environment value with the `STATE_` prefix.
void saveState(String name, String value)
=> _echo('save-state', value, {'name': name});

void startGroup(String name) => _echo('group', name);
void endGroup() => _echo('endgroup');

Future<T> group<T>(String name, Future<T> Function() function) async {
  startGroup(name);
  T result;
  try {
    result = await function();
  } finally {
    endGroup();
  }
  return result;
}

void _echo(String command, [String message, Map<String, String> parameters]) {
  final sb = StringBuffer('::$command');
  if (parameters != null) {
    final params =
        parameters.entries.map((e) => '${e.key}=${e.value}').join(',');
    if (params.isNotEmpty) sb.write(' $params');
  }
  sb.write('::');
  if (message != null) sb.write(message);
  stdout.writeln(sb.toString());
}
