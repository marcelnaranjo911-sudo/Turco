
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_scope.dart';
import '../models/enums.dart';
import '../models/turno.dart';
import '../utils/formatters.dart';
import '../utils/navegacion.dart';
import '../viewmodels/agenda_view_model.dart';
import '../viewmodels/salon_view_model.dart';
import '../viewmodels/turno_form_view_model.dart';
import '../widgets/acciones_turno.dart';
import '../widgets/componentes.dart';
import '../widgets/turno_card.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key, this.estilistaId});

  /// Llega desde la ruta /agenda?estilista=ID
  final int? estilistaId;

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  @override
  void initState() {
    super.initState();
    _aplicarParametro();
  }

  @override
  void didUpdateWidget(covariant AgendaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.estilistaId != widget.estilistaId) _aplicarParametro();
  }

  void _aplicarParametro() {
    final id = widget.estilistaId;
    if (id == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppScope.of(context).agenda.setEstilista(id);
    });
  }

  void _acciones(BuildContext context, SalonViewModel salon, Turno t) {
    if (t.estado != EstadoTurno.programado) return;
    final cliente = salon.clientePorId(t.clienteId)?.nombre ?? '';
    final estilista = salon.estilistaPorId(t.estilistaId)?.nombre ?? '';
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$cliente · ${horaTexto(t.inicio)}',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                  '${t.servicios.map((s) => s.nombre).join(' + ')} · $estilista',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.check_circle_outline, color: cs.tertiary),
                title: const Text('Marcar como completado'),
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  completarTurno(context, salon, t);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.block, color: cs.error),
                title: Text('Cancelar turno', style: TextStyle(color: cs.error)),
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  cancelarTurno(context, salon, t);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    final salon = deps.salon;
    final vm = deps.agenda;
    final cs = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: Listenable.merge([salon, vm]),
      builder: (context, _) {
        final turnos = vm.turnos;
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.content_cut, size: 18, color: cs.onPrimary),
                ),
                const SizedBox(width: 12),
                const Text('Turco'),
              ],
            ),
            actions: [
              PopupMenuButton<ThemeMode>(
                icon: const Icon(Icons.brightness_6_outlined),
                tooltip: 'Tema',
                onSelected: deps.tema.cambiar,
                itemBuilder: (_) => [
                  CheckedPopupMenuItem(
                      value: ThemeMode.system,
                      checked: deps.tema.modo == ThemeMode.system,
                      child: const Text('Sistema')),
                  CheckedPopupMenuItem(
                      value: ThemeMode.light,
                      checked: deps.tema.modo == ThemeMode.light,
                      child: const Text('Claro')),
                  CheckedPopupMenuItem(
                      value: ThemeMode.dark,
                      checked: deps.tema.modo == ThemeMode.dark,
                      child: const Text('Oscuro')),
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => abrirFormularioTurno(context,
                inicial: TurnoFormInicial(fecha: vm.fecha)),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo turno'),
          ),
          // Toda la pantalla desplaza: la cabecera es el ítem 0 del ListView.builder.
          body: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            itemCount: 1 + (turnos.isEmpty ? 1 : turnos.length),
            itemBuilder: (context, i) {
              if (i == 0) return _Cabecera(salon: salon, vm: vm);
              if (turnos.isEmpty) {
                return const EstadoVacio(
                  icono: Icons.event_busy,
                  titulo: 'No hay turnos para este día',
                  mensaje:
                  'Crea el primer turno con el botón de abajo o cambia los filtros.',
                );
              }
              final t = turnos[i - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TurnoCard(
                  turno: t,
                  clienteNombre:
                  salon.clientePorId(t.clienteId)?.nombre ?? 'Cliente eliminado',
                  estilistaNombre: salon.estilistaPorId(t.estilistaId)?.nombre ?? '',
                  onTap: () => context.push('/turno/${t.id}'),
                  onLongPress: () => _acciones(context, salon, t),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera({required this.salon, required this.vm});
  final SalonViewModel salon;
  final AgendaViewModel vm;

  Future<void> _elegirFecha(BuildContext context) async {
    final d = await showDatePicker(
      context: context,
      initialDate: vm.fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Elegir fecha',
    );
    if (d != null) vm.irAFecha(d);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final resumen = vm.resumen;
    final semana = vm.semana;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabecera de la semana
        Row(
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Semana anterior',
              onPressed: vm.semanaAnterior,
              icon: const Icon(Icons.chevron_left),
            ),
            Flexible(
              child: Text(mesAnio(vm.fecha),
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleMedium?.copyWith(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Semana siguiente',
              onPressed: vm.semanaSiguiente,
              icon: const Icon(Icons.chevron_right),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _elegirFecha(context),
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: const Text('Elegir fecha'),
            ),
          ],
        ),
        // Tira de 7 días (ListView.builder horizontal)
        SizedBox(
          height: 64,
          child: LayoutBuilder(
            builder: (context, c) => ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemExtent: c.maxWidth / 7,
              itemCount: semana.length,
              itemBuilder: (context, i) {
                final dia = semana[i];
                final sel = mismoDia(dia, vm.fecha);
                final domingo = dia.weekday == DateTime.sunday;
                final colorTexto = sel ? cs.onPrimary : cs.onSurface;
                return Opacity(
                  opacity: domingo ? .4 : 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: sel ? cs.primary : null,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => vm.irAFecha(dia),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(diaCorto(dia),
                                style: tt.labelSmall?.copyWith(
                                    color: sel
                                        ? cs.onPrimary
                                        : cs.onSurfaceVariant)),
                            const SizedBox(height: 2),
                            Text('${dia.day}',
                                style: tt.titleMedium?.copyWith(
                                    color: colorTexto,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text('Domingo: salón cerrado',
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 10),
        // Resumen del día
        Row(
          children: [
            _Resumen('${resumen.programados}', 'Programados', cs.primary),
            const SizedBox(width: 8),
            _Resumen('${resumen.completados}', 'Completados', cs.tertiary),
            const SizedBox(width: 8),
            _Resumen(precioTexto(resumen.ingreso), 'Ingreso est.', cs.onSurface),
          ],
        ),
        const SizedBox(height: 10),
        // Filtro por estilista
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('Todos'),
                  selected: vm.estilistaId == null,
                  onSelected: (_) => vm.setEstilista(null),
                ),
              ),
              for (final e in salon.estilistas)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(primerNombre(e.nombre)),
                    selected: vm.estilistaId == e.id,
                    onSelected: (_) => vm.setEstilista(e.id),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Filtro por estado
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<FiltroEstado>(
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
            segments: const [
              ButtonSegment(
                  value: FiltroEstado.todos,
                  label: FittedBox(child: Text('Todos'))),
              ButtonSegment(
                  value: FiltroEstado.programados,
                  label: FittedBox(child: Text('Program.'))),
              ButtonSegment(
                  value: FiltroEstado.completados,
                  label: FittedBox(child: Text('Complet.'))),
              ButtonSegment(
                  value: FiltroEstado.cancelados,
                  label: FittedBox(child: Text('Cancel.'))),
            ],
            selected: {vm.estado},
            onSelectionChanged: (s) => vm.setEstado(s.first),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _Resumen extends StatelessWidget {
  const _Resumen(this.valor, this.etiqueta, this.color);
  final String valor;
  final String etiqueta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(valor,
                    style: tt.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ),
              Text(etiqueta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}