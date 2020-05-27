import 'dart:io';

/// Logging commands
const log = Log._();

class Log {
  const Log._();

  Map<String, String> _params(String file, String line, String column) {
    final map = <String, String>{};
    if (file != null) map['file'] = file;
    if (line != null) map['line'] = line;
    if (column != null) map['col'] = column;
    return map;
  }

  void _log(
    String command,
    String message,
    String file,
    String line,
    String column,
  ) =>
      _echo(command, message, _params(file, line, column));

  void info(String message) => stdout.writeln(message);

  /// Creates an error message and prints the message to the log.
  ///
  /// You can optionally provide a filename ([file]), line number ([line]), and column ([column]) number where the warning occurred.
  void error(
    String message, {
    String file,
    String line,
    String column,
  }) =>
      _log('error', message, file, line, column);

  /// Creates a warning message and prints the message to the log.
  ///
  /// You can optionally provide a filename ([file]), line number ([line]), and column ([column]) number where the warning occurred.
  void warning(
    String message, {
    String file,
    String line,
    String column,
  }) =>
      _log('warning', message, file, line, column);

  /// Prints a debug message to the log.
  ///
  /// You must create a secret named `ACTIONS_STEP_DEBUG` with the value `true`
  /// to see the debug messages set by this command in the log.
  /// To learn more about creating secrets and using them in a step,
  /// see "[Creating and using encrypted secrets.](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets)"
  void debug(
    String message, {
    String file,
    String line,
    String column,
  }) =>
      _log('debug', message, file, line, column);

  /// All logs written after you call this function
  /// will be grouped together,
  /// until you call [endGroup].
  void startGroup(String name) => _echo('group', name);
  void endGroup() => _echo('endgroup');

  /// All logs written while executing the [function]
  /// will be grouped together.
  ///
  /// The group will be closed after it finishes,
  /// or in case an exception occurs.
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
}

/// Creates or updates an environment variable
/// for this action AND any actions running next in a job.
///
/// Environment variables are case-sensitive and you can include punctuation.
void exportVariable(String name, String value) {
  _echo('set-env', value, {'name': name});
  Platform.environment[name] = value;
}

/// Alias for [exportVariable]
void setEnvironmentVariable(String name, String value) =>
    exportVariable(name, value);

/// Sets an action's output parameter.
///
/// Optionally, you can also declare output parameters in an action's metadata file.
/// For more information,
/// see "[Metadata syntax for GitHub Actions.](https://help.github.com/en/articles/metadata-syntax-for-github-actions#outputs)"
void setOutput(String name, String value) =>
    _echo('set-output', value, {'name': name});

/// Prepends a directory to the system `PATH` variable
/// for this action AND all subsequent actions in the current job.
void addPath(String path) {
  _echo('add-path', path);
  final currentPath = Platform.environment['PATH'] ?? '';
  Platform.environment['PATH'] = '$path${Platform.pathSeparator}$currentPath';
}

/// True iff the secret `ACTIONS_STEP_DEBUG` is set with the value `true`
bool get isDebug => Platform.environment['RUNNER_DEBUG'] == '1';

/// Masking a value prevents a string or variable from being printed in the log.
///
/// Each masked word separated by whitespace is replaced with the `*` character.
/// You can use an environment variable or string for the mask's [value].
void maskValueInLog(String value) => _echo('add-mask', value);

/// Alias for [maskValueInLog]
void setSecret(String value) => maskValueInLog(value);

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
void saveState(String name, String value) {
  _echo('save-state', value, {'name': name});
  Platform.environment['STATE_$name'] = value;
}

/// Gets the value of a state set using [saveState]
String getState(String name) => Platform.environment['STATE_$name'];

void _echo(String command, [String message, Map<String, String> parameters]) {
  final sb = StringBuffer('::$command');
  final params =
      parameters?.entries?.map((e) => '${e.key}=${e.value}')?.join(',');
  if (params != null && params.isNotEmpty) sb.write(' $params');
  sb.write('::');
  if (message != null) sb.write(message);
  stdout.writeln(sb.toString());
}
