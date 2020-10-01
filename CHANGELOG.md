# Changelog

## 0.0.5

- **Fix**: streamed outputs of processes were incorrectly decoded in UTF-8.
- **Fix**: the toolkit won't try to edit the environment variables of the current running action.
- [File commands](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-commands-for-github-actions#environment-files) have been implemented.

## 0.0.4

- Rename `workDir` argument by `workingDirectory` for `exec` and `execInParallel` functions.
- `exec` and `execInParallel` now return a `ProcessResult`.
- `exec` and `execInParallel` don't block `stdout` and `stderr` StreamConsumers anymore.

## 0.0.3

- The `exec` function can now be unawaited.
- New function `execInParallel`.
- More documentation.

## 0.0.2

- Newly created environment variables and paths are accessible to the running action.
- Incorrect workflow command parameters fixed.
- New getters `isDebug` and `getState`.
- New getters for the default environment under `env`.
- `setErrorMessage`, `setWarningMessage` and `setDebugMessage` replaced by `log.error`, `log.warning` and `log.debug`
- `group`, `startGroup` and `endGroup` moved under `log`.

## 0.0.1

- Initial version, created by Stagehand
