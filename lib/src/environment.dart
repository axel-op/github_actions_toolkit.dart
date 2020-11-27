import 'dart:io';

/// Getters to access properties of the default environment
/// set by GitHub
const env = Env._();

class Env {
  const Env._();

  String? _env(String variable) => Platform.environment[variable];

  /// The path to the GitHub home directory used to store user data.
  ///
  /// For example, `/github/home`.
  String? get home => _env('HOME');

  /// The name of the workflow.
  String? get workflow => _env('GITHUB_WORKFLOW');

  /// A unique number for each run within a repository.
  ///
  /// This number does not change if you re-run the workflow run.
  int? get runId => int.tryParse(_env('GITHUB_RUN_ID') ?? '');

  /// The unique identifier (id) of the action.
  String? get actionId => _env('GITHUB_ACTION');

  /// The name of the person or app that initiated the workflow.
  ///
  /// For example, `octocat`.
  String? get actor => _env('GITHUB_ACTOR');

  /// The owner and repository name.
  ///
  /// For example, `octocat/Hello-World`.
  String? get repository => _env('GITHUB_REPOSITORY');

  /// The name of the webhook event that triggered the workflow.
  String? get eventName => _env('GITHUB_EVENT_NAME');

  /// The complete webhook event payload (JSON formatted).
  ///
  /// See https://developer.github.com/v3/activity/events/types
  String? get eventPayload {
    final path = _env('GITHUB_EVENT_PATH');
    if (path == null) return null;
    final file = File(path);
    return file.existsSync() ? file.readAsStringSync() : null;
  }

  /// The GitHub workspace directory.
  ///
  /// The workspace directory contains a subdirectory with a copy of your repository
  /// if your workflow uses the [`actions/checkout`](https://github.com/actions/checkout) action.
  /// If you don't use the `actions/checkout` action, the directory will be empty.
  Directory? get workspace {
    final path = _env('GITHUB_WORKSPACE');
    if (path == null) return null;
    return Directory(path);
  }

  /// The commit SHA that triggered the workflow.
  ///
  /// For example, `ffac537e6cbbf934b08745a378932722df287a53`.
  String? get sha => _env('GITHUB_SHA');

  /// The branch or tag ref that triggered the workflow.
  ///
  /// For example, `refs/heads/feature-branch-1`.
  ///
  /// If neither a branch or tag is available for the event type,
  /// the variable will not exist.
  String? get ref => _env('GITHUB_REF');

  /// **Only set for forked repositories**. The branch of the head repository.
  String? get headRef => _env('GITHUB_HEAD_REF');

  /// **Only set for forked repositories**. The branch of the base repository.
  String? get baseRef => _env('GITHUB_BASE_REF');
}
