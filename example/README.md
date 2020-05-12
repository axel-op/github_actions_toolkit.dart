# Example

## Usage

### Logging

Logging commands are available under `log`.

There are four levels:

- `error`
- `warning`
- `info`
- `debug`

Logs with `info` level will have no particular emphasis and be directly transmitted to `stdout`.

Logs with `debug` level will only appear if the secret `ACTIONS_STEP_DEBUG` has been created in the repository with the value `true` (see "[Creating and using encrypted secrets](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets)").

```dart
import 'package:github_actions_toolkit/github_actions_toolkit.dart' as gaction;

main() async {
  const logger = gaction.log;
  
  logger
    ..info('This is just a message')
    ..warning('This is a warning message')
    ..error('This is an error message');

  // [isDebug] will be true iff the secret `ACTIONS_STEP_DEBUG` has been configured
  if (gaction.isDebug) logger.debug('This is a debug message');
}
```

### Inputs

Create an `Input` object for each input that your action needs, and retrieve their value with the `value` getter.

This getter will throw an `ArgumentError` if the input is missing while it is required.

```dart
import 'package:github_actions_toolkit/github_actions_toolkit.dart' as gaction;

main() async {
  const input = gaction.Input(
    'who-to-greet', // name defined in the YAML file
    isRequired: true,
    canBeEmpty: false,
  );

  logger.info('Hello ${input.value}!');
}
```

### Outputs

Set an output for subsequent steps with `setOutput`.

### Subprocesses

Execute a command in the shell with the `exec` function. It will return an `ExecResult` object once the command has terminated with its exit code and its outputs.

```dart
import 'package:github_actions_toolkit/github_actions_toolkit.dart' as gaction;

main() async {
  final process = gaction.exec('echo', ['hello world']);

  gaction
    .log
    .info("The 'echo' command has terminated with code ${process.exitCode} and has printed ${process.stdout}");
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/axel-op/github_actions_toolkit.dart
