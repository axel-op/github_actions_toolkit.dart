import 'dart:io';

/// Objects that represent an input of the action
class Input {
  /// The name of the input,
  /// as written in the YAML file.
  final String name;
  final bool isRequired;

  /// True if the value can be an empty string.
  final bool canBeEmpty;

  const Input(
    this.name, {
    required this.isRequired,
    this.canBeEmpty = true,
  });

  /// Will throw an [ArgumentError]
  /// if the input is required and the value is null
  /// or if the value is an empty string and [canBeEmpty] is false.
  String? get value {
    final key = 'INPUT_${name.toUpperCase().replaceAll(" ", "_")}';
    final value = Platform.environment[key];
    if ((value == null && isRequired) ||
        (value != null && value.isEmpty && !canBeEmpty)) {
      throw ArgumentError('No value was given for the argument \'$name\'.');
    }
    return value;
  }
}
