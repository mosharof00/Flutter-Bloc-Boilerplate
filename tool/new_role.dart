import 'dart:convert';
import 'dart:io';

/// Generates a role shell and registers it.
///
/// `dart run tool/new_role.dart student`
///
/// Run from the project root. Domain and data stay shared.
void main(List<String> args) {
  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    stdout.writeln('Usage: dart run tool/new_role.dart <snake_name>');
    exit(args.isEmpty ? 64 : 0);
  }

  final name = args.first;
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
    stderr.writeln('Role name must be snake_case, for example student.');
    exit(64);
  }

  final pascal = _pascal(name);
  final camel = _camel(name);
  if (Directory('lib/app/roles/$name').existsSync()) {
    stderr.writeln('Role $name already exists.');
    exit(64);
  }

  _write(
    'lib/app/roles/$name/${name}_home_view_model.dart',
    _viewModel(pascal),
  );
  _write(
    'lib/app/roles/$name/${name}_home_screen.dart',
    _screen(name, pascal, camel),
  );
  _write('lib/app/roles/$name/${name}_shell.dart', _shell(name, pascal));
  _write(
    'lib/app/roles/$name/${name}_role_module.dart',
    _module(name, pascal, camel),
  );

  _insertBefore(
    File('lib/core/access/app_role.dart'),
    '// GENERATOR: roles',
    '  $camel,\n  ',
  );
  _insertBefore(
    File('lib/core/access/permission.dart'),
    '// GENERATOR: permissions',
    '  view${pascal}Home,\n  ',
  );
  _insertBefore(
    File('lib/core/access/role_permissions.dart'),
    '// GENERATOR: role-permissions',
    '        AppRole.$camel: <Permission>{Permission.view${pascal}Home},\n        ',
  );
  _insertBefore(
    File('lib/app/router/app_routes.dart'),
    '// GENERATOR: routes',
    "  static const ${camel}Home = '/$name';\n  ",
  );
  _insertBefore(
    File('lib/app/roles/role_label.dart'),
    '// GENERATOR: role-labels',
    '    AppRole.$camel => l10n.role$pascal,\n    ',
  );
  _ensureImports(File('lib/app/role_modules.dart'), <String>[
    'package:enterprise_mvvm/app/roles/$name/${name}_role_module.dart',
  ]);
  _insertBefore(
    File('lib/app/role_modules.dart'),
    '// GENERATOR: role-modules',
    '    const ${pascal}RoleModule(),\n    ',
  );
  _addArbKey(File('lib/l10n/app_en.arb'), 'role$pascal', _title(name));
  _addArbKey(File('lib/l10n/app_bn.arb'), 'role$pascal', _title(name));
  _addArbKey(File('lib/l10n/app_en.arb'), '${camel}HomeTitle', _title(name));
  _addArbKey(File('lib/l10n/app_bn.arb'), '${camel}HomeTitle', _title(name));

  stdout.writeln(
    'Created the $name role. Run the app again so l10n regenerates.',
  );
}

String _pascal(String snake) {
  return snake
      .split('_')
      .map(
        (String part) =>
            part.isEmpty ? '' : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join();
}

String _camel(String snake) {
  final pascal = _pascal(snake);
  return '${pascal[0].toLowerCase()}${pascal.substring(1)}';
}

String _title(String snake) {
  return _pascal(snake).replaceAllMapped(
    RegExp('(?<=.)([A-Z])'),
    (Match match) => ' ${match.group(1)}',
  );
}

void _write(String path, String contents) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(contents.endsWith('\n') ? contents : '$contents\n');
}

void _insertBefore(File file, String marker, String insertion) {
  final source = file.readAsStringSync();
  final pattern = RegExp(
    '^(?<indent>[ \\t]*)${RegExp.escape(marker)}',
    multiLine: true,
  );
  final match = pattern.firstMatch(source);
  if (match == null) {
    stderr.writeln('Missing marker $marker in ${file.path}');
    exit(1);
  }
  final indent = match.namedGroup('indent')!;
  final rawLines = insertion
      .replaceFirst(RegExp(r'^\n'), '')
      .replaceFirst(RegExp(r'\n$'), '')
      .split('\n')
      .where((String line) => line.trim().isNotEmpty)
      .toList();
  if (rawLines.isEmpty || source.contains(rawLines.first.trim())) {
    return;
  }
  final base = RegExp(r'^ *').firstMatch(rawLines.first)!.group(0)!.length;
  final block = rawLines
      .map((String line) {
        final content = line.trimLeft();
        final relative = line.length - content.length - base;
        final extra = relative < 0 ? 0 : relative;
        return '$indent${' ' * extra}$content';
      })
      .join('\n');
  final updated = source.replaceRange(match.start, match.start, '$block\n');
  file.writeAsStringSync(updated.endsWith('\n') ? updated : '$updated\n');
}

void _ensureImports(File file, List<String> uris) {
  final lines = file.readAsLinesSync();
  final imports = <String>[];
  final rest = <String>[];
  var header = true;
  for (final line in lines) {
    if (header && (line.startsWith('import ') || line.trim().isEmpty)) {
      if (line.startsWith('import ')) {
        imports.add(line);
      }
      continue;
    }
    header = false;
    rest.add(line);
  }
  for (final uri in uris) {
    final line = "import '$uri';";
    if (!imports.contains(line)) {
      imports.add(line);
    }
  }
  imports.sort();
  file.writeAsStringSync(
    '${imports.join('\n')}\n\n${rest.join('\n').trim()}\n',
  );
}

void _addArbKey(File file, String key, String value) {
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    stderr.writeln('${file.path} is not a JSON object.');
    exit(1);
  }
  decoded.putIfAbsent(key, () => value);
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(decoded)}\n',
  );
}

String _viewModel(String pascal) =>
    '''
import 'package:enterprise_mvvm/features/auth/ui/session/session_view_model.dart';

final class ${pascal}HomeViewModel extends SessionViewModel {
  ${pascal}HomeViewModel({
    required super.sessionRepository,
    required super.authRepository,
  });
}
''';

String _screen(String snake, String pascal, String camel) {
  final imports = <String>[
    'package:enterprise_mvvm/app/roles/$snake/${snake}_home_view_model.dart',
    'package:enterprise_mvvm/app/roles/role_home_screen.dart',
    'package:enterprise_mvvm/l10n/app_localizations.dart',
    'package:flutter/material.dart',
  ]..sort();
  final directives = imports.map((String uri) => "import '$uri';").join('\n');
  return '''
$directives

class ${pascal}HomeScreen extends StatelessWidget {
  const ${pascal}HomeScreen({required this.viewModel, super.key});

  final ${pascal}HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return RoleHomeScreen(
      title: AppLocalizations.of(context).${camel}HomeTitle,
      viewModel: viewModel,
    );
  }
}
''';
}

String _shell(String snake, String pascal) =>
    '''
import 'dart:async';

import 'package:enterprise_mvvm/app/app_scope.dart';
import 'package:enterprise_mvvm/app/roles/$snake/${snake}_home_screen.dart';
import 'package:enterprise_mvvm/app/roles/$snake/${snake}_home_view_model.dart';
import 'package:flutter/material.dart';

class ${pascal}Shell extends StatefulWidget {
  const ${pascal}Shell({super.key});

  @override
  State<${pascal}Shell> createState() => _${pascal}ShellState();
}

class _${pascal}ShellState extends State<${pascal}Shell> {
  ${pascal}HomeViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dependencies = AppScope.of(context);
    _viewModel ??= ${pascal}HomeViewModel(
      sessionRepository: dependencies.sessionRepository,
      authRepository: dependencies.authRepository,
    );
  }

  @override
  void dispose() {
    final viewModel = _viewModel;
    if (viewModel != null) {
      unawaited(viewModel.close());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel;
    if (viewModel == null) {
      return const SizedBox.shrink();
    }
    return ${pascal}HomeScreen(viewModel: viewModel);
  }
}
''';

String _module(String snake, String pascal, String camel) {
  final imports = <String>[
    'package:enterprise_mvvm/app/roles/$snake/${snake}_shell.dart',
    'package:enterprise_mvvm/app/roles/app_role_module.dart',
    'package:enterprise_mvvm/app/roles/role_context.dart',
    'package:enterprise_mvvm/app/router/app_routes.dart',
    'package:enterprise_mvvm/core/access/app_role.dart',
    'package:enterprise_mvvm/core/access/permission.dart',
    'package:enterprise_mvvm/core/access/role_destination.dart',
    'package:enterprise_mvvm/l10n/app_localizations.dart',
    'package:flutter/widgets.dart',
    'package:get_it/get_it.dart',
    'package:go_router/go_router.dart',
  ]..sort();
  final directives = imports.map((String uri) => "import '$uri';").join('\n');
  return '''
$directives

final class ${pascal}RoleModule extends AppRoleModule {
  const ${pascal}RoleModule();

  @override
  AppRole get role => AppRole.$camel;

  @override
  String get homePath => AppRoutes.${camel}Home;

  @override
  Permission get homePermission => Permission.view${pascal}Home;

  @override
  List<RoleDestination> get destinations => const <RoleDestination>[
    RoleDestination(labelKey: '${camel}HomeTitle', path: AppRoutes.${camel}Home),
  ];

  @override
  String title(AppLocalizations l10n) => l10n.${camel}HomeTitle;

  @override
  GoRoute route() {
    return GoRoute(
      path: homePath,
      builder: (BuildContext context, GoRouterState state) =>
          const ${pascal}Shell(),
    );
  }

  @override
  void registerScope(GetIt scope) {
    scope.registerSingleton<RoleContext>(const RoleContext(AppRole.$camel));
  }
}
''';
}
