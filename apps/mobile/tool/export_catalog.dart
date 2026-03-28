import 'dart:convert';
import 'dart:io';

import 'package:mobile/infrastructure/database/catalog_seed.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/export_catalog.dart <output-path> [more-output-paths]',
    );
    exitCode = 64;
    return;
  }

  final catalog = buildOfficialCatalogSeed();
  final encoder = JsonEncoder.withIndent('  ');
  final content = '${encoder.convert(catalog.toMap())}\n';

  for (final rawPath in arguments) {
    final output = File(rawPath);
    await output.parent.create(recursive: true);
    await output.writeAsString(content);
    stdout.writeln('Exported catalog to ${output.path}');
  }
}
