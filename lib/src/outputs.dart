import 'processes.dart';

Future<void> setOutput(
  String name,
  String value,
) async {
  ArgumentError.checkNotNull(name);
  ArgumentError.checkNotNull(value);
  await exec('echo', ['::set-output name=$name::$value']);
}
