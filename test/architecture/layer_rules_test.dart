import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('layer rules, package imports, and barrel files', () {
    final violations = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File file) => file.path.endsWith('.dart'))
        .where((File file) => !file.path.endsWith('.g.dart'))
        .where(
          (File file) => !file.path.contains(
            '${Platform.pathSeparator}gen${Platform.pathSeparator}',
          ),
        )
        .where((File file) => !file.path.contains('app_localizations'));

    final directive = RegExp('(?:import|export)\\s+[\'"]([^\'"]+)[\'"]');

    for (final file in files) {
      final source = file.readAsStringSync();
      final path = file.path.replaceAll('\\', '/');
      final imports = directive
          .allMatches(source)
          .map((RegExpMatch match) => match.group(1)!)
          .toList();

      if (_isBarrel(source)) {
        violations.add('$path is a barrel file');
      }

      for (final uri in imports) {
        if (!uri.startsWith('package:') && !uri.startsWith('dart:')) {
          violations.add('$path uses a relative import: $uri');
        }
        if (uri.contains('package:get_it/') && !_isUnder(path, 'lib/app')) {
          violations.add('$path imports get_it outside lib/app');
        }
        if (_isUnder(path, 'lib/core') &&
            (uri.contains('/features/') || uri.contains('/app/'))) {
          violations.add('$path (core) imports $uri');
        }
        if (path.contains('/domain/') &&
            (uri.contains('/data/') ||
                uri.contains('/ui/') ||
                uri.contains('package:flutter') ||
                uri.contains('package:dio'))) {
          violations.add('$path (domain) imports $uri');
        }
        if (path.contains('/ui/') && uri.contains('/data/')) {
          violations.add('$path (ui) imports $uri');
        }
        _checkCrossFeature(path, uri, violations);
        _checkRepository(path, uri, violations);
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}

bool _isUnder(String path, String folder) {
  return path.contains('/$folder/') || path.startsWith('$folder/');
}

bool _isBarrel(String source) {
  final withoutBlocks = source.replaceAll(
    RegExp(r'/\*.*?\*/', dotAll: true),
    '',
  );
  final lines = withoutBlocks
      .split('\n')
      .map((String line) {
        final comment = line.indexOf('//');
        final code = comment == -1 ? line : line.substring(0, comment);
        return code.trim();
      })
      .where((String line) => line.isNotEmpty)
      .toList();
  if (lines.isEmpty ||
      !lines.any((String line) => line.startsWith('export '))) {
    return false;
  }
  return lines.every(
    (String line) =>
        line.startsWith('export ') ||
        line.startsWith('library ') ||
        line == 'library;',
  );
}

void _checkCrossFeature(String path, String uri, List<String> violations) {
  final owner = RegExp(r'/features/([^/]+)/').firstMatch(path);
  final imported = RegExp(r'/features/([^/]+)/').firstMatch(uri);
  if (owner == null || imported == null) {
    return;
  }
  if (owner.group(1) == imported.group(1)) {
    return;
  }
  if (uri.contains('/domain/models/')) {
    return;
  }
  violations.add('$path imports another feature: $uri');
}

void _checkRepository(String path, String uri, List<String> violations) {
  if (!path.contains('/data/repositories/')) {
    return;
  }
  final owner = RegExp(r'/features/([^/]+)/').firstMatch(path)?.group(1);
  if (uri.contains('/data/repositories/')) {
    violations.add('$path imports another repository implementation: $uri');
  }
  if (!uri.contains('repository')) {
    return;
  }
  final ownContract =
      owner != null && uri.contains('/features/$owner/domain/repositories/');
  final sessionContract = uri.contains('/core/session/session_repository.dart');
  if (!ownContract && !sessionContract) {
    violations.add('$path imports another repository: $uri');
  }
}
