
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/turno_form_view_model.dart';
import '../views/agenda_screen.dart';
import '../views/clientes_screen.dart';
import '../views/detalle_turno_screen.dart';
import '../views/estilistas_screen.dart';
import '../views/servicios_screen.dart';
import '../views/shell_screen.dart';
import '../views/turno_form_screen.dart';

final GlobalKey<NavigatorState> _rootKey =
GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter crearRouter() {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/agenda',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellScreen(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/agenda',
              builder: (context, state) => AgendaScreen(
                estilistaId:
                int.tryParse(state.uri.queryParameters['estilista'] ?? ''),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/clientes',
              builder: (context, state) => const ClientesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/servicios',
              builder: (context, state) => const ServiciosScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/estilistas',
              builder: (context, state) => const EstilistasScreen(),
            ),
          ]),
        ],
      ),
      // Se abren por encima de la barra inferior (navigator raíz).
      // "/turno/nuevo" va antes que "/turno/:id".
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/turno/nuevo',
        builder: (context, state) => TurnoFormScreen(
          inicial: state.extra is TurnoFormInicial
              ? state.extra as TurnoFormInicial
              : null,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/turno/:id',
        builder: (context, state) => DetalleTurnoScreen(
          turnoId: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
        ),
        routes: [
          GoRoute(
            parentNavigatorKey: _rootKey,
            path: 'editar',
            builder: (context, state) => TurnoFormScreen(
              turnoId: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
            ),
          ),
        ],
      ),
    ],
  );
}