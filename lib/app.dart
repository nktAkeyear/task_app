import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/task_repository.dart';
import 'ui/shell.dart';

class RepoScope extends InheritedNotifier<TaskRepository> {
  const RepoScope({
    required TaskRepository repository,
    required super.child,
    super.key,
  }) : super(notifier: repository);

  static TaskRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RepoScope>();
    assert(scope != null, 'RepoScope is missing');
    return scope!.notifier!;
  }
}

class TasApp extends StatelessWidget {
  const TasApp({required this.repository, super.key});

  final TaskRepository repository;

  @override
  Widget build(BuildContext context) {
    return RepoScope(
      repository: repository,
      child: ListenableBuilder(
        listenable: repository,
        builder: (context, _) {
          return MaterialApp(
            title: 'Tas',
            debugShowCheckedModeBanner: false,
            locale: Locale(_localeCode(repository.language)),
            supportedLocales: const [Locale('ja'), Locale('en'), Locale('ko')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: tasTheme(Brightness.light, seed: repository.accent),
            darkTheme: tasTheme(Brightness.dark, seed: repository.accent),
            themeMode: repository.themeMode,
            scrollBehavior: const TasScrollBehavior(),
            home: const TasShell(),
          );
        },
      ),
    );
  }
}

class TasErrorApp extends StatelessWidget {
  const TasErrorApp({required this.detail, super.key});

  final String detail;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ja'),
      theme: tasTheme(Brightness.light),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 36),
                const SizedBox(height: 12),
                const Text(
                  'データを開けませんでした。',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(detail, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text('アプリを再起動してもう一度試してください。'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TasScrollBehavior extends MaterialScrollBehavior {
  const TasScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

const accentSeeds = <int>[
  0xFF1C4E4A,
  0xFF2F5D9F,
  0xFFC46B2D,
  0xFF8A3E6B,
  0xFF5C4A8A,
];

String _localeCode(String language) {
  return switch (language) {
    'en' => 'en',
    'ko' => 'ko',
    _ => 'ja',
  };
}

ThemeData tasTheme(Brightness brightness, {int seed = 0xFF1C4E4A}) {
  final light = brightness == Brightness.light;
  final seeded = ColorScheme.fromSeed(
    seedColor: Color(seed),
    brightness: brightness,
  );
  final scheme = seeded.copyWith(
    surface: light ? const Color(0xFFF7F6F3) : const Color(0xFF141614),
    surfaceContainerLow: light ? Colors.white : const Color(0xFF1C1F1C),
    surfaceContainerHigh: light
        ? const Color(0xFFEBE8E2)
        : const Color(0xFF2A2E2A),
    onSurface: light ? const Color(0xFF1C1B19) : const Color(0xFFF3F1EA),
    onSurfaceVariant: light ? const Color(0xFF4E4A43) : const Color(0xFFCBC6BC),
    outlineVariant: light ? const Color(0xFFD4CFC6) : const Color(0xFF3A3F3A),
    error: light ? const Color(0xFF9F1D1D) : const Color(0xFFFFB4AB),
  );
  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    fontFamilyFallback: const [
      'Noto Sans CJK JP',
      'Noto Sans JP',
      'Droid Sans Fallback',
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(44, 44),
        shape: buttonShape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 44),
        shape: buttonShape,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    dividerColor: scheme.outlineVariant,
    listTileTheme: const ListTileThemeData(minTileHeight: 52),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
