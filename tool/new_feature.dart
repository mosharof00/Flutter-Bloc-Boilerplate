import 'dart:convert';
import 'dart:io';

/// Generates a feature slice.
///
/// `dart run tool/new_feature.dart orders`
/// `dart run tool/new_feature.dart orders --use-case`
///
/// Run from the project root, then:
/// `dart run build_runner build --delete-conflicting-outputs`
void main(List<String> args) {
  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    stdout.writeln(
      'Usage: dart run tool/new_feature.dart <snake_name> [--use-case]',
    );
    exit(args.isEmpty ? 64 : 0);
  }

  final useCase = args.contains('--use-case');
  final name = args.firstWhere((String arg) => !arg.startsWith('--'));
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
    stderr.writeln('Feature name must be snake_case, for example orders.');
    exit(64);
  }

  final pascal = _pascal(name);
  final camel = _camel(name);
  final root = Directory.current;
  final featurePath = 'lib/features/$name';
  if (Directory(featurePath).existsSync()) {
    stderr.writeln('Feature $name already exists.');
    exit(64);
  }

  _write('$featurePath/domain/models/$name.dart', _model(pascal));
  _write(
    '$featurePath/domain/repositories/${name}_repository.dart',
    _repositoryContract(pascal),
  );
  if (useCase) {
    _write(
      '$featurePath/domain/use_cases/get_$name.dart',
      _useCase(name, pascal),
    );
  } else {
    _write('$featurePath/domain/use_cases/.gitkeep', '');
  }
  _write('$featurePath/data/dto/${name}_dto.dart', _dto(pascal));
  _write('$featurePath/data/dto/${name}_mapper.dart', _mapper(name, pascal));
  _write(
    '$featurePath/data/services/${name}_api_service.dart',
    _service(name, pascal),
  );
  _write(
    '$featurePath/data/repositories/${name}_repository_impl.dart',
    _repositoryImpl(name, pascal),
  );
  _write(
    '$featurePath/ui/$name/${name}_view_model.dart',
    _viewModel(name, pascal, useCase: useCase),
  );
  _write(
    '$featurePath/ui/$name/${name}_screen.dart',
    _screen(name, pascal, camel),
  );
  _write(
    'lib/app/di/register_$name.dart',
    _registration(name, pascal, useCase: useCase),
  );
  _write('test/fakes/fake_${name}_repository.dart', _fake(name, pascal));
  _write(
    'test/features/$name/${name}_view_model_test.dart',
    _test(name, pascal, useCase: useCase),
  );

  _insertBefore(
    File('lib/app/router/app_routes.dart'),
    '// GENERATOR: routes',
    "  static const $camel = '/$name';\n  ",
  );
  _ensureImports(File('lib/app/di/register_features.dart'), <String>[
    'package:enterprise_mvvm/app/di/register_$name.dart',
  ]);
  _insertBefore(
    File('lib/app/di/register_features.dart'),
    '// GENERATOR: feature-registrations',
    '  register$pascal(getIt);\n  ',
  );
  _ensureImports(File('lib/app/router/feature_routes.dart'), <String>[
    'package:enterprise_mvvm/app/router/app_routes.dart',
    'package:enterprise_mvvm/core/ui/view_model/view_model_host.dart',
    'package:enterprise_mvvm/core/ui/view_model/view_state.dart',
    'package:enterprise_mvvm/features/$name/domain/models/$name.dart',
    if (useCase)
      'package:enterprise_mvvm/features/$name/domain/use_cases/get_$name.dart'
    else
      'package:enterprise_mvvm/features/$name/domain/repositories/${name}_repository.dart',
    'package:enterprise_mvvm/features/$name/ui/$name/${name}_screen.dart',
    'package:enterprise_mvvm/features/$name/ui/$name/${name}_view_model.dart',
  ]);
  _insertBefore(
    File('lib/app/router/feature_routes.dart'),
    '// GENERATOR: feature-routes',
    _route(name, pascal, camel, useCase: useCase),
  );
  _addArbKey(File('lib/l10n/app_en.arb'), '${camel}Title', _title(name));
  _addArbKey(File('lib/l10n/app_bn.arb'), '${camel}Title', _title(name));

  stdout.writeln('Created feature $name under ${root.path}.');
  stdout.writeln(
    'Run: dart run build_runner build --delete-conflicting-outputs',
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

String _title(String snake) => _pascal(snake).replaceAllMapped(
  RegExp('(?<=.)([A-Z])'),
  (Match match) => ' ${match.group(1)}',
);

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
  final body = rest.join('\n').trim();
  file.writeAsStringSync('${imports.join('\n')}\n\n$body\n');
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

String _model(String pascal) =>
    '''
import 'package:equatable/equatable.dart';

final class $pascal with Equatable {
  const $pascal({required this.id, required this.title});

  final String id;
  final String title;

  @override
  List<Object?> get props => <Object?>[id, title];
}
''';

String _repositoryContract(String pascal) =>
    '''
import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:enterprise_mvvm/features/${_snake(pascal)}/domain/models/${_snake(pascal)}.dart';

abstract interface class ${pascal}Repository {
  Future<Result<List<$pascal>>> fetch();
}
''';

String _snake(String pascal) {
  return pascal
      .replaceAllMapped(
        RegExp('(?<=.)([A-Z])'),
        (Match match) => '_${match.group(1)}',
      )
      .toLowerCase();
}

String _useCase(String snake, String pascal) =>
    '''
import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:enterprise_mvvm/features/$snake/domain/models/$snake.dart';
import 'package:enterprise_mvvm/features/$snake/domain/repositories/${snake}_repository.dart';

final class Get${pascal}UseCase {
  const Get${pascal}UseCase(this._repository);

  final ${pascal}Repository _repository;

  Future<Result<List<$pascal>>> call() => _repository.fetch();
}
''';

String _dto(String pascal) =>
    '''
import 'package:json_annotation/json_annotation.dart';

part '${_snake(pascal)}_dto.g.dart';

@JsonSerializable()
class ${pascal}Dto {
  const ${pascal}Dto({required this.id, required this.title});

  factory ${pascal}Dto.fromJson(Map<String, dynamic> json) =>
      _\$${pascal}DtoFromJson(json);

  final String id;
  final String title;

  Map<String, dynamic> toJson() => _\$${pascal}DtoToJson(this);
}
''';

String _mapper(String snake, String pascal) =>
    '''
import 'package:enterprise_mvvm/features/$snake/data/dto/${snake}_dto.dart';
import 'package:enterprise_mvvm/features/$snake/domain/models/$snake.dart';

extension ${pascal}DtoMapper on ${pascal}Dto {
  $pascal toDomain() => $pascal(id: id, title: title);
}
''';

String _service(String snake, String pascal) =>
    '''
import 'package:dio/dio.dart';
import 'package:enterprise_mvvm/core/network/dio_failure_mapper.dart';
import 'package:enterprise_mvvm/features/$snake/data/dto/${snake}_dto.dart';

abstract interface class ${pascal}ApiService {
  Future<List<${pascal}Dto>> fetch();
}

final class ${pascal}ApiServiceImpl implements ${pascal}ApiService {
  ${pascal}ApiServiceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<${pascal}Dto>> fetch() async {
    try {
      final response = await _dio.get<List<dynamic>>('/$snake');
      final data = response.data ?? <dynamic>[];
      return data
          .whereType<Map<String, dynamic>>()
          .map(${pascal}Dto.fromJson)
          .toList();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
''';

String _repositoryImpl(String snake, String pascal) =>
    '''
import 'package:enterprise_mvvm/core/error/app_exception.dart';
import 'package:enterprise_mvvm/core/error/failure.dart';
import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:enterprise_mvvm/features/$snake/data/dto/${snake}_dto.dart';
import 'package:enterprise_mvvm/features/$snake/data/dto/${snake}_mapper.dart';
import 'package:enterprise_mvvm/features/$snake/data/services/${snake}_api_service.dart';
import 'package:enterprise_mvvm/features/$snake/domain/models/$snake.dart';
import 'package:enterprise_mvvm/features/$snake/domain/repositories/${snake}_repository.dart';

final class ${pascal}RepositoryImpl implements ${pascal}Repository {
  ${pascal}RepositoryImpl(this._api);

  final ${pascal}ApiService _api;

  @override
  Future<Result<List<$pascal>>> fetch() async {
    try {
      final dtos = await _api.fetch();
      return Success<List<$pascal>>(
        dtos.map((${pascal}Dto dto) => dto.toDomain()).toList(),
      );
    } on NetworkException {
      return const Err<List<$pascal>>(NetworkFailure());
    } on UnauthorizedException {
      return const Err<List<$pascal>>(UnauthorizedFailure());
    } on AppException {
      return const Err<List<$pascal>>(UnknownFailure());
    }
  }
}
''';

String _viewModel(String snake, String pascal, {required bool useCase}) {
  if (useCase) {
    return '''
import 'package:enterprise_mvvm/core/ui/view_model/base_view_model.dart';
import 'package:enterprise_mvvm/core/ui/view_model/view_state.dart';
import 'package:enterprise_mvvm/features/$snake/domain/models/$snake.dart';
import 'package:enterprise_mvvm/features/$snake/domain/use_cases/get_$snake.dart';

final class ${pascal}ViewModel extends BaseViewModel<ViewState<List<$pascal>>> {
  ${pascal}ViewModel(this._useCase) : super(const ViewIdle<List<$pascal>>());

  final Get${pascal}UseCase _useCase;

  Future<void> load() {
    return run<List<$pascal>>(
      action: _useCase.call,
      onLoading: () => const ViewLoading<List<$pascal>>(),
      onSuccess: ViewSuccess<List<$pascal>>.new,
      onFailure: ViewFailure<List<$pascal>>.new,
    );
  }
}
''';
  }
  return '''
import 'package:enterprise_mvvm/core/ui/view_model/base_view_model.dart';
import 'package:enterprise_mvvm/core/ui/view_model/view_state.dart';
import 'package:enterprise_mvvm/features/$snake/domain/models/$snake.dart';
import 'package:enterprise_mvvm/features/$snake/domain/repositories/${snake}_repository.dart';

final class ${pascal}ViewModel extends BaseViewModel<ViewState<List<$pascal>>> {
  ${pascal}ViewModel(this._repository) : super(const ViewIdle<List<$pascal>>());

  final ${pascal}Repository _repository;

  Future<void> load() {
    return run<List<$pascal>>(
      action: _repository.fetch,
      onLoading: () => const ViewLoading<List<$pascal>>(),
      onSuccess: ViewSuccess<List<$pascal>>.new,
      onFailure: ViewFailure<List<$pascal>>.new,
    );
  }
}
''';
}

String _screen(String snake, String pascal, String camel) =>
    '''
import 'dart:async';

import 'package:enterprise_mvvm/core/theme/app_tokens.dart';
import 'package:enterprise_mvvm/core/ui/view_model/view_state.dart';
import 'package:enterprise_mvvm/core/ui/widgets/async_view.dart';
import 'package:enterprise_mvvm/core/ui/widgets/gradient_scaffold.dart';
import 'package:enterprise_mvvm/features/$snake/domain/models/$snake.dart';
import 'package:enterprise_mvvm/features/$snake/ui/$snake/${snake}_view_model.dart';
import 'package:enterprise_mvvm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ${pascal}Screen extends StatefulWidget {
  const ${pascal}Screen({required this.viewModel, super.key});

  final ${pascal}ViewModel viewModel;

  @override
  State<${pascal}Screen> createState() => _${pascal}ScreenState();
}

class _${pascal}ScreenState extends State<${pascal}Screen> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.viewModel.load());
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).${camel}Title)),
      body: BlocBuilder<${pascal}ViewModel, ViewState<List<$pascal>>>(
        bloc: widget.viewModel,
        builder: (BuildContext context, ViewState<List<$pascal>> state) {
          return AsyncView<List<$pascal>>(
            state: state,
            onRetry: widget.viewModel.load,
            isEmpty: (List<$pascal> items) => items.isEmpty,
            onData: (List<$pascal> items) {
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: items.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (BuildContext context, int index) {
                  return Text(items[index].title);
                },
              );
            },
          );
        },
      ),
    );
  }
}
''';

String _registration(String snake, String pascal, {required bool useCase}) {
  final imports = <String>[
    'package:dio/dio.dart',
    'package:enterprise_mvvm/features/$snake/data/repositories/${snake}_repository_impl.dart',
    'package:enterprise_mvvm/features/$snake/data/services/${snake}_api_service.dart',
    'package:enterprise_mvvm/features/$snake/domain/repositories/${snake}_repository.dart',
    if (useCase)
      'package:enterprise_mvvm/features/$snake/domain/use_cases/get_$snake.dart',
    'package:get_it/get_it.dart',
  ]..sort();
  final useCaseLines = useCase
      ? '''
  getIt.registerFactory<Get${pascal}UseCase>(
    () => Get${pascal}UseCase(getIt<${pascal}Repository>()),
  );
'''
      : '';
  final directives = imports.map((String uri) => "import '$uri';").join('\n');
  return '''
$directives

void register$pascal(GetIt getIt) {
  getIt.registerLazySingleton<${pascal}ApiService>(
    () => ${pascal}ApiServiceImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<${pascal}Repository>(
    () => ${pascal}RepositoryImpl(getIt<${pascal}ApiService>()),
  );
$useCaseLines}
''';
}

String _route(
  String snake,
  String pascal,
  String camel, {
  required bool useCase,
}) {
  final dependency = useCase
      ? 'getIt<Get${pascal}UseCase>()'
      : 'getIt<${pascal}Repository>()';
  return '''
    GoRoute(
      path: AppRoutes.$camel,
      builder: (BuildContext context, GoRouterState state) {
        return ViewModelHost<${pascal}ViewModel, ViewState<List<$pascal>>>(
          create: () => ${pascal}ViewModel($dependency),
          builder: (${pascal}ViewModel viewModel) =>
              ${pascal}Screen(viewModel: viewModel),
        );
      },
    ),
  ''';
}

String _fake(String snake, String pascal) =>
    '''
import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:enterprise_mvvm/features/$snake/domain/models/$snake.dart';
import 'package:enterprise_mvvm/features/$snake/domain/repositories/${snake}_repository.dart';

final class Fake${pascal}Repository implements ${pascal}Repository {
  @override
  Future<Result<List<$pascal>>> fetch() async {
    return const Success<List<$pascal>>(<$pascal>[]);
  }
}
''';

String _test(String snake, String pascal, {required bool useCase}) {
  final build = useCase
      ? '${pascal}ViewModel(Get${pascal}UseCase(Fake${pascal}Repository()))'
      : '${pascal}ViewModel(Fake${pascal}Repository())';
  final useCaseImport = useCase
      ? "import 'package:enterprise_mvvm/features/$snake/domain/use_cases/get_$snake.dart';\n"
      : '';
  return '''
import 'package:bloc_test/bloc_test.dart';
import 'package:enterprise_mvvm/core/ui/view_model/view_state.dart';
import 'package:enterprise_mvvm/features/$snake/domain/models/$snake.dart';
${useCaseImport}import 'package:enterprise_mvvm/features/$snake/ui/$snake/${snake}_view_model.dart';

import '../../fakes/fake_${snake}_repository.dart';

void main() {
  blocTest<${pascal}ViewModel, ViewState<List<$pascal>>>(
    'load emits loading then an empty success',
    build: () => $build,
    act: (${pascal}ViewModel viewModel) => viewModel.load(),
    expect: () => const <ViewState<List<$pascal>>>[
      ViewLoading<List<$pascal>>(),
      ViewSuccess<List<$pascal>>(<$pascal>[]),
    ],
  );
}
''';
}
