# github_actions_toolkit

A third-party toolkit for [GitHub Actions](https://help.github.com/en/actions) coded in Dart. It is inspired by the official Javascript [`actions/toolkit`](https://github.com/actions/toolkit/) and contains similar commands.

Check out [this gist](https://gist.github.com/axel-op/deff66ac2f28a01813193d90de36c564) for different templates to create a GitHub Action in Dart.

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

  // [isDebug] is true iff the secret `ACTIONS_STEP_DEBUG` has been configured
  final message = gaction.isDebug
      ? 'This is a debug message'
      : 'This is a debug message that you will not see';
  logger.debug(message);
}
```

### Inputs

Create an `Input` object for each input that your action needs, and retrieve their value with the `value` getter.

This getter will throw an `ArgumentError` if the input had been set as required and is missing.

```dart
import 'package:github_actions_toolkit/github_actions_toolkit.dart' as gaction;

main() async {
  const input = gaction.Input(
    'who-to-greet', // name defined in the YAML file
    isRequired: true,
  );

  gaction
    .log
    .info('Hello ${input.value}!');
}
```

### Outputs

Set an output for subsequent steps with `setOutput`.

### Subprocesses

Execute a command in the shell with the `exec` function. It will return an `ExecResult` object once the command has terminated with its exit code and its outputs.

```dart
import 'package:github_actions_toolkit/github_actions_toolkit.dart' as gaction;

main() async {
  final process = await gaction.exec('echo', ['Hello world']);

  gaction
    .log
    .info("The 'echo' command has terminated with code ${process.exitCode} and has printed ${process.stdout}");
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/axel-op/github_actions_toolkit.dart
