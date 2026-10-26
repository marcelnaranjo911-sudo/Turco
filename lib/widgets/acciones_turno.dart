
import 'package:flutter/material.dart';

import '../models/turno.dart';
import '../utils/formatters.dart';
import '../viewmodels/salon_view_model.dart';
import 'dialogos.dart';

Future<void> completarTurno(
    BuildContext context, SalonViewModel salon, Turno t) async {
  final nombre = salon.clientePorId(t.clienteId)?.nombre ?? 'el cliente';
  final ok = await confirmar(
    context,
    titulo: '¿Marcar como completado?',
    mensaje:
    'El turno de $nombre (${horaTexto(t.inicio)} a ${horaTexto(t.fin)}) pasará a completado y ya no podrá editarse.',
    textoConfirmar: 'Completar',
    icono: Icons.check_circle_outline,
  );
  if (!ok || !context.mounted) return;
  salon.completar(t.id);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text('Turno completado')));
}

Future<void> cancelarTurno(
    BuildContext context, SalonViewModel salon, Turno t) async {
  final nombre = salon.clientePorId(t.clienteId)?.nombre ?? 'el cliente';
  final ok = await confirmar(
    context,
    titulo: '¿Cancelar este turno?',
    mensaje:
    'El horario de $nombre (${horaTexto(t.inicio)} a ${horaTexto(t.fin)}) quedará libre. Esta acción no se puede deshacer.',
    textoConfirmar: 'Cancelar turno',
    destructivo: true,
  );
  if (!ok || !context.mounted) return;
  salon.cancelar(t.id);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text('Turno cancelado')));
}