
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_scope.dart';
import '../viewmodels/turno_form_view_model.dart';
import 'formatters.dart';

/// Abre el formulario de nuevo turno y procesa el valor devuelto con pop.
Future<void> abrirFormularioTurno(
    BuildContext context, {
      TurnoFormInicial? inicial,
    }) async {
  final resultado =
  await context.push<TurnoGuardado>('/turno/nuevo', extra: inicial);
  if (resultado == null || !context.mounted) return;
  procesarTurnoGuardado(context, resultado);
}

/// Muestra el SnackBar de confirmación y lleva la Agenda a la fecha del turno.
void procesarTurnoGuardado(BuildContext context, TurnoGuardado r) {
  AppScope.of(context).agenda.irAFecha(r.fecha);
  final router = GoRouter.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
            'Turno ${r.esNuevo ? 'guardado' : 'actualizado'} para el ${fechaCorta(r.fecha)}'),
        action: SnackBarAction(
          label: 'Ver',
          onPressed: () => router.push('/turno/${r.id}'),
        ),
      ),
    );
}

/// Volver a la pantalla anterior (o a la agenda si no hay historial).
void volver(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/agenda');
  }
}