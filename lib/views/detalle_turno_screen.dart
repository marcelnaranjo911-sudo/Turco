
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_scope.dart';
import '../models/enums.dart';
import '../models/turno.dart';
import '../utils/formatters.dart';
import '../utils/navegacion.dart';
import '../viewmodels/salon_view_model.dart';
import '../viewmodels/turno_form_view_model.dart';
import '../widgets/acciones_turno.dart';
import '../widgets/componentes.dart';

/// Pantalla para ids inexistentes (la app no se cierra).
class TurnoNoEncontrado extends StatelessWidget {
  const TurnoNoEncontrado({super.key, required this.titulo, required this.mensaje});
  final String titulo;
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del turno')),
      body: SingleChildScrollView(
        child: EstadoVacio(
          icono: Icons.search_off,
          esError: true,
          titulo: titulo,
          mensaje: mensaje,
          accion: FilledButton.icon(
            onPressed: () => context.go('/agenda'),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Volver a la agenda'),
          ),
        ),
      ),
    );
  }
}

class DetalleTurnoScreen extends StatelessWidget {
  const DetalleTurnoScreen({super.key, required this.turnoId});
  final int turnoId;

  Future<void> _editar(BuildContext context) async {
    final r = await context.push<TurnoGuardado>('/turno/$turnoId/editar');
    if (r != null && context.mounted) procesarTurnoGuardado(context, r);
  }

  @override
  Widget build(BuildContext context) {
    final salon = AppScope.of(context).salon;
    return ListenableBuilder(
      listenable: salon,
      builder: (context, _) {
        final t = salon.turnoPorId(turnoId);
        if (t == null) {
          return const TurnoNoEncontrado(
            titulo: 'No encontramos este turno',
            mensaje: 'El turno no existe o ya no está disponible.',
          );
        }
        return _Detalle(
          turno: t,
          salon: salon,
          onEditar: () => _editar(context),
        );
      },
    );
  }
}

class _Detalle extends StatelessWidget {
  const _Detalle(
      {required this.turno, required this.salon, required this.onEditar});
  final Turno turno;
  final SalonViewModel salon;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cliente = salon.clientePorId(turno.clienteId);
    final estilista = salon.estilistaPorId(turno.estilistaId);
    final programado = turno.estado == EstadoTurno.programado;

    Widget dato(IconData icono, String etiqueta, String valor) => Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Icon(icono, size: 18, color: cs.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etiqueta,
                    style: tt.labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant)),
                Text(valor,
                    style: tt.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del turno')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: cs.primaryContainer,
                        foregroundColor: cs.onPrimaryContainer,
                        child: Text(inicial(cliente?.nombre ?? '?'),
                            style: tt.titleMedium?.copyWith(
                                fontSize: 19, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cliente?.nombre ?? 'Cliente eliminado',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tt.titleMedium?.copyWith(
                                    fontSize: 17, fontWeight: FontWeight.w600)),
                            if (cliente != null)
                              Row(children: [
                                Icon(Icons.phone_outlined,
                                    size: 13, color: cs.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(telefonoTexto(cliente.telefono),
                                    style: tt.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant)),
                              ]),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      EstadoBadge(estado: turno.estado),
                    ],
                  ),
                  dato(Icons.calendar_today_outlined, 'Fecha',
                      fechaLarga(turno.inicio)),
                  dato(Icons.schedule, 'Hora',
                      '${horaTexto(turno.inicio)} a ${horaTexto(turno.fin)} (${duracionTexto(turno.duracionMin)})'),
                  dato(Icons.person_outline, 'Estilista', estilista?.nombre ?? '—'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Servicios',
                      style: tt.titleMedium?.copyWith(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  for (final s in turno.servicios) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.nombre,
                                  style: tt.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w500)),
                              Text('${s.duracionMin} min',
                                  style: tt.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Text(precioTexto(s.precio),
                            style: tt.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Divider(height: 18, color: cs.outlineVariant),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total',
                          style: tt.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      Text(precioTexto(turno.total),
                          style: tt.titleMedium?.copyWith(
                              color: cs.primary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notas',
                      style: tt.titleMedium?.copyWith(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  _NotasScroll(texto: turno.notas ?? 'Sin notas'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Creado el ${fechaNumerica(turno.creadoEn)} · Modificado el ${fechaNumerica(turno.modificadoEn)}',
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
      bottomNavigationBar: Material(
        color: cs.surfaceContainer,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: programado
                ? Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEditar,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const FittedBox(child: Text('Editar')),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => completarTurno(context, salon, turno),
                    icon: const Icon(Icons.check, size: 18),
                    label: const FittedBox(child: Text('Completar')),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: cs.error),
                    onPressed: () => cancelarTurno(context, salon, turno),
                    icon: const Icon(Icons.block, size: 18),
                    label: const FittedBox(child: Text('Cancelar')),
                  ),
                ),
              ],
            )
                : SizedBox(
              height: 46,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline,
                      size: 16, color: cs.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Turno ${turno.estado.etiqueta.toLowerCase()}: solo lectura',
                    style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Notas con scroll propio y altura máxima (sin overflow con textos largos).
class _NotasScroll extends StatefulWidget {
  const _NotasScroll({required this.texto});
  final String texto;

  @override
  State<_NotasScroll> createState() => _NotasScrollState();
}

class _NotasScrollState extends State<_NotasScroll> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 140),
      child: Scrollbar(
        controller: _controller,
        child: SingleChildScrollView(
          controller: _controller,
          child: Text(widget.texto,
              style: tt.bodyMedium?.copyWith(
                  height: 1.45,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
      ),
    );
  }
}