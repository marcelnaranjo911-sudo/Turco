
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'app_scope.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const TurcoApp());
}

class TurcoApp extends StatefulWidget {
  const TurcoApp({super.key});

  @override
  State<TurcoApp> createState() => _TurcoAppState();
}

class _TurcoAppState extends State<TurcoApp> {
  // Inyección de dependencias simple: se crean una sola vez.
  final AppDependencies _deps = AppDependencies();
  late final GoRouter _router = crearRouter();

  @override
  Widget build(BuildContext context) {
    return AppScope(
      deps: _deps,
      child: ListenableBuilder(
        listenable: _deps.tema,
        builder: (context, _) {
          return MaterialApp.router(
            title: 'Turco',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.claro,
            darkTheme: AppTheme.oscuro,
            themeMode: _deps.tema.modo,
            routerConfig: _router,
            locale: const Locale('es'),
            supportedLocales: const [Locale('es'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
          );
        },
      ),
    );
  }
}