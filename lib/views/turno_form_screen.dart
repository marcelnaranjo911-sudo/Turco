
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_scope.dart';
import '../models/enums.dart';
import '../utils/formatters.dart';
import '../utils/navegacion.dart';
import '../viewmodels/turno_form_view_model.dart';
import '../widgets/cliente_form_sheet.dart';
import '../widgets/componentes.dart';
import '../widgets/dialogos.dart';
import 'detalle_turno_screen.dart';

/// Crea (turnoId == null) o edita (turnoId != null) un turno.
class TurnoFormScreen extends StatefulWidget {
  const TurnoFormScreen({super.key, this.turnoId, this.inicial});
  final int? turnoId;
  final TurnoFormInicial? inicial;

  @override
  State<TurnoFormScreen> createState() => _TurnoFormScreenState();
}

class _TurnoFormScreenState extends State<TurnoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fCliente = FocusNode();
  final _fServicios = FocusNode();
  final _fEstilista = FocusNode();
  final _fFecha = FocusNode();
  final _fHora = FocusNode();
  final _fNotas = FocusNode();

  TurnoFormViewModel? _vm;
  TextEditingController? _notas;
  String? _errorCarga;
  bool _salir = false;

  @override
  void initState() {
    super.initState();
    final salon = AppScope.of(context).salon;
    if (widget.turnoId != null) {
      final t = salon.turnoPorId(widget.turnoId!);
      if (t == null) {
        _errorCarga = 'No encontramos este turno';
      } else if (t.estado != EstadoTurno.programado) {
        _errorCarga = 'Este turno ya no se puede editar';
      } else {
        _vm = TurnoFormViewModel(salon, editar: t);
      }
    } else {
      _vm = TurnoFormViewModel(salon, inicial: widget.inicial);
    }
    if (_vm != null) _notas = TextEditingController(text: _vm!.notas);
  }

  @override
  void dispose() {
    for (final f in [_fCliente, _fServicios, _fEstilista, _fFecha, _fHora, _fNotas]) {
      f.dispose();
    }
    _notas?.dispose();
    _vm?.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ salida
  void _cerrar([TurnoGuardado? resultado]) {
    setState(() => _salir = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop(resultado);
    });
  }

  Future<void> _intentarSalir() async {
    if (!_vm!.hayCambios) {
      _cerrar();
      return;
    }
    final descartar = await confirmar(
      context,
      titulo: '¿Descartar los cambios?',
      mensaje:
      'Tienes cambios sin guardar en este turno. Si sales ahora se perderán.',
      textoCancelar: 'Seguir editando',
      textoConfirmar: 'Descartar',
      destructivo: true,
    );
    if (descartar && mounted) _cerrar();
  }

  // ----------------------------------------------------------- acciones
  void _snack(String texto) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto)));

  Future<void> _elegirCliente() async {
    final salon = AppScope.of(context).salon;
    final id = await elegirOpcion<int>(
      context,
      titulo: 'Selecciona un cliente',
      seleccionado: _vm!.clienteId,
      opciones: [
        for (final c in salon.clientes)
          OpcionLista(c.id, c.nombre, telefonoTexto(c.telefono)),
      ],
    );
    if (id != null) _vm!.setCliente(id);
  }

  Future<void> _crearCliente() async {
    final c = await mostrarFormularioCliente(context);
    if (c != null) _vm!.setCliente(c.id);
  }

  Future<void> _elegirEstilista() async {
    final vm = _vm!;
    if (vm.serviciosIds.isEmpty) {
      _snack('Primero elige los servicios');
      return;
    }
    final opciones = vm.estilistasDisponibles;
    if (opciones.isEmpty) {
      _snack('Ningún estilista realiza todos los servicios elegidos');
      return;
    }
    final id = await elegirOpcion<int>(
      context,
      titulo: 'Selecciona un estilista',
      seleccionado: vm.estilistaId,
      opciones: [for (final e in opciones) OpcionLista(e.id, e.nombre)],
    );
    if (id != null) vm.setEstilista(id);
  }

  Future<void> _elegirFecha() async {
    final hoy = soloFecha(DateTime.now());
    var inicial = _vm!.fecha ?? hoy;
    if (inicial.isBefore(hoy)) inicial = hoy;
    if (inicial.weekday == DateTime.sunday) {
      inicial = DateTime(inicial.year, inicial.month, inicial.day + 1);
    }
    final d = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: hoy,
      lastDate: DateTime(hoy.year + 1, hoy.month, hoy.day),
      helpText: 'Fecha del turno',
      selectableDayPredicate: (d) => d.weekday != DateTime.sunday,
    );
    if (d != null) _vm!.setFecha(d);
  }

  void _toggleServicio(int id) {
    final limpio = _vm!.toggleServicio(id);
    if (limpio) {
      _snack('El estilista elegido ya no realiza todos los servicios. Elige otro.');
    }
  }

  void _guardar() {
    FocusScope.of(context).unfocus();
    final vm = _vm!;
    final formOk = _formKey.currentState!.validate();
    final vmOk = vm.validar();
    if (!formOk || !vmOk) {
      _enfocarPrimerError(formOk);
      return;
    }
    final r = vm.guardar();
    if (r.error != null) {
      _snack(r.error!);
      return;
    }
    _cerrar(TurnoGuardado(
      id: r.turno!.id,
      fecha: soloFecha(r.turno!.inicio),
      esNuevo: !vm.esEdicion,
    ));
  }

  /// El foco va al primer campo (en orden visual) con error de validación.
  void _enfocarPrimerError(bool formOk) {
    final vm = _vm!;
    final orden = <(FocusNode, bool)>[
      (_fCliente, vm.errorCliente != null),
      (_fServicios, vm.errorServicios != null),
      (_fEstilista, vm.errorEstilista != null),
      (_fFecha, vm.errorFecha != null),
      (_fHora, vm.errorHora != null),
      (_fNotas, !formOk),
    ];
    for (final (nodo, hayError) in orden) {
      if (!hayError) continue;
      nodo.requestFocus();
      final ctx = nodo.context;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx,
            duration: const Duration(milliseconds: 300), alignment: .15);
      }
      break;
    }
  }

  // --------------------------------------------------------------- UI
  @override
  Widget build(BuildContext context) {
    final vm = _vm;
    if (vm == null) {
      return TurnoNoEncontrado(
        titulo: _errorCarga ?? 'No encontramos este turno',
        mensaje: 'Solo se pueden editar turnos programados que existan.',
      );
    }
    final salon = AppScope.of(context).salon;

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final cliente =
        vm.clienteId == null ? null : salon.clientePorId(vm.clienteId!);
        final estilista =
        vm.estilistaId == null ? null : salon.estilistaPorId(vm.estilistaId!);
        final tt = Theme.of(context).textTheme;
        final cs = Theme.of(context).colorScheme;

        return PopScope(
          canPop: !vm.hayCambios || _salir,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _intentarSalir();
          },
          child: Scaffold(
            appBar: AppBar(
                title: Text(vm.esEdicion ? 'Editar turno' : 'Nuevo turno')),
            body: Form(
              key: _formKey,
              child: ListView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  // ---- Cliente
                  CampoToque(
                    focusNode: _fCliente,
                    etiqueta: 'Cliente',
                    icono: Icons.person_outline,
                    hint: 'Selecciona un cliente',
                    texto: cliente?.nombre,
                    errorText: vm.errorCliente,
                    onTap: _elegirCliente,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _crearCliente,
                      icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                      label: const Text('Crear cliente nuevo'),
                    ),
                  ),
                  // ---- Servicios
                  Text('Servicios para',
                      style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<FiltroGenero>(
                      segments: [
                        for (final f in FiltroGenero.values)
                          ButtonSegment(value: f, label: Text(f.etiqueta)),
                      ],
                      selected: {vm.filtro},
                      onSelectionChanged: (s) => vm.setFiltro(s.first),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Focus(
                    focusNode: _fServicios,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Servicios',
                            style: tt.titleMedium?.copyWith(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        for (final cat in CategoriaServicio.values)
                          if (vm.serviciosVisibles(cat).isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(cat.etiqueta.toUpperCase(),
                                style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final s in vm.serviciosVisibles(cat))
                                  FilterChip(
                                    label: Text(s.nombre),
                                    tooltip:
                                    '${duracionTexto(s.duracionMin)} · ${precioTexto(s.precio)}',
                                    selected: vm.serviciosIds.contains(s.id),
                                    onSelected: (_) => _toggleServicio(s.id),
                                  ),
                              ],
                            ),
                          ],
                        if (vm.errorServicios != null)
                          ErrorTexto(vm.errorServicios!),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // ---- Estilista
                  CampoToque(
                    focusNode: _fEstilista,
                    etiqueta: 'Estilista',
                    icono: Icons.content_cut,
                    hint: vm.serviciosIds.isEmpty
                        ? 'Primero elige los servicios'
                        : (vm.estilistasDisponibles.isEmpty
                        ? 'Ningún estilista realiza todos los servicios'
                        : 'Selecciona un estilista'),
                    texto: estilista?.nombre,
                    errorText: vm.errorEstilista,
                    onTap: _elegirEstilista,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Solo se muestran estilistas que realizan todos los servicios elegidos.',
                          style: tt.labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // ---- Fecha
                  CampoToque(
                    focusNode: _fFecha,
                    etiqueta: 'Fecha',
                    icono: Icons.calendar_today_outlined,
                    hint: 'Selecciona una fecha',
                    texto: vm.fecha == null ? null : fechaLarga(vm.fecha!),
                    errorText: vm.errorFecha,
                    onTap: _elegirFecha,
                  ),
                  const SizedBox(height: 18),
                  // ---- Hora (GridView.builder)
                  _SeccionHora(vm: vm, focusNode: _fHora),
                  const SizedBox(height: 18),
                  // ---- Notas
                  TextFormField(
                    controller: _notas,
                    focusNode: _fNotas,
                    maxLength: 500,
                    minLines: 3,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    onChanged: vm.setNotas,
                    decoration: const InputDecoration(
                      labelText: 'Notas (opcional)',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => (v ?? '').length > 500
                        ? 'Máximo 500 caracteres'
                        : null,
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Material(
              color: cs.surfaceContainer,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _DatoResumen(Icons.schedule, duracionTexto(vm.duracionMin)),
                            _DatoResumen(Icons.flag_outlined,
                                'Fin ${vm.fin == null ? '--:--' : horaTexto(vm.fin!)}'),
                            _DatoResumen(Icons.sell_outlined,
                                precioTexto(vm.total),
                                negrita: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _intentarSalir,
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _guardar,
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Guardar turno'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DatoResumen extends StatelessWidget {
  const _DatoResumen(this.icono, this.texto, {this.negrita = false});
  final IconData icono;
  final String texto;
  final bool negrita;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 14, color: cs.primary),
        const SizedBox(width: 4),
        Text(texto,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: negrita ? FontWeight.w700 : FontWeight.w600)),
      ],
    );
  }
}

class _SeccionHora extends StatelessWidget {
  const _SeccionHora({required this.vm, required this.focusNode});
  final TurnoFormViewModel vm;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final franjas = vm.franjas;
    final hayLibres = franjas.any((f) => f.disponible);
    final error = vm.errorHora;

    Widget leyenda(Widget punto, String texto) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        punto,
        const SizedBox(width: 4),
        Text(texto,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );

    Widget cuadro({Color? relleno, Color? borde}) => Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: relleno,
        borderRadius: BorderRadius.circular(3),
        border: borde == null ? null : Border.all(color: borde),
      ),
    );

    return Focus(
      focusNode: focusNode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hora de inicio',
              style: tt.titleMedium
                  ?.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              leyenda(cuadro(borde: cs.outline), 'Libre'),
              leyenda(cuadro(relleno: cs.surfaceContainerHighest), 'No disponible'),
              leyenda(cuadro(relleno: cs.primary), 'Elegida'),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: franjas.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.1,
            ),
            itemBuilder: (context, i) {
              final f = franjas[i];
              final elegida = vm.horaMin == f.minutos;
              final Color fondo = elegida
                  ? cs.primary
                  : (f.disponible ? cs.surface : cs.surfaceContainerHighest);
              final Color texto = elegida
                  ? cs.onPrimary
                  : (f.disponible
                  ? cs.onSurface
                  : cs.onSurface.withValues(alpha: .38));
              return Material(
                color: fondo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: (f.disponible && !elegida)
                      ? BorderSide(color: error != null ? cs.error : cs.outline)
                      : BorderSide.none,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: f.disponible ? () => vm.setHora(f.minutos) : null,
                  child: Center(
                    child: Text(f.texto,
                        style: tt.bodySmall?.copyWith(
                            color: texto,
                            fontWeight:
                            elegida ? FontWeight.w600 : FontWeight.w500)),
                  ),
                ),
              );
            },
          ),
          if (vm.fecha == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Elige primero la fecha para ver las franjas libres.',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            )
          else if (!hayLibres)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                  'No quedan franjas libres con esta combinación. Prueba otra fecha, otro estilista o menos servicios.',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ),
          if (error != null) ErrorTexto(error),
        ],
      ),
    );
  }
}