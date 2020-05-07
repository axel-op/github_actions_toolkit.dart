import 'dart:io';

import 'package:meta/meta.dart';

class Input {
  final String name;
  final bool isRequired;

  /// True if the value can be an empty string.
  final bool canBeEmpty;

  const Input(
    this.name, {
    @required this.isRequired,
    @required this.canBeEmpty,
  });

  /// Will throw an [ArgumentError]
  /// if the input is required and the value is null
  /// or if the value is an empty string and [canBeEmpty] is false.
  String get value {
    final v = Platform
        .environment['INPUT_${name.toUpperCase().replaceAll(" ", "_")}'];
    if ((v == null && isRequired) || (v != null && v.isEmpty && !canBeEmpty)) {
      throw ArgumentError('No value was given for the argument \'$name\'.');
    }
    return v;
  }
}
