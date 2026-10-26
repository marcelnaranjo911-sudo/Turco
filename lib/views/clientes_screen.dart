
import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/cliente.dart';
import '../models/enums.dart';
import '../utils/formatters.dart';
import '../utils/navegacion.dart';
import '../viewmodels/clientes_view_model.dart';
import '../viewmodels/salon_view_model.dart';
import '../viewmodels/turno_form_view_model.dart';
import '../widgets/cliente_detalle_sheet.dart';
import '../widgets/cliente_form_sheet.dart';
import '../widgets/componentes.dart';
import '../widgets/dialogos.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  late final TextEditingController _busqueda;

  @override
  void initState() {
    super.initState();
    // Se conserva el texto de búsqueda al cambiar de pestaña.
    _busqueda =
        TextEditingController(text: AppScope.of(context).clientes.consulta);
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  void _snack(String t) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(t)));

  Future<void> _nuevo() async {
    final c = await mostrarFormularioCliente(context);
    if (c != null && mounted) _snack('Cliente ${c.nombre} registrado');
  }

  Future<void> _abrir(Cliente c) async {
    final deps = AppScope.of(context);
    final salon = deps.salon;
    final accion = await mostrarDetalleCliente(context, c.id);
    if (accion == null || !mounted) return;
    switch (accion) {
      case AccionCliente.nuevoTurno:
        await abrirFormularioTurno(context,
            inicial: TurnoFormInicial(clienteId: c.id, fecha: deps.agenda.fecha));
      case AccionCliente.editar:
        final cli = salon.clientePorId(c.id);
        if (cli == null) return;
        final r = await mostrarFormularioCliente(context, cliente: cli);
        if (r != null && mounted) _snack('Cliente actualizado');
      case AccionCliente.eliminar:
        await _eliminar(salon, c);
    }
  }

  Future<void> _eliminar(SalonViewModel salon, Cliente c) async {
    final n = salon.programadosDeCliente(c.id);
    if (n > 0) {
      _snack(
          'No se puede eliminar: ${c.nombre} tiene $n turno${n == 1 ? '' : 's'} programado${n == 1 ? '' : 's'}.');
      return;
    }
    final ok = await confirmar(
      context,
      titulo: '¿Eliminar a ${c.nombre}?',
      mensaje:
      'Se eliminará el cliente junto con su historial de turnos completados y cancelados.',
      textoCancelar: 'Cancelar',
      textoConfirmar: 'Eliminar',
      destructivo: true,
    );
    if (!ok || !mounted) return;
    salon.eliminarCliente(c.id);
    _snack('Cliente eliminado');
  }

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    final salon = deps.salon;
    final vm = deps.clientes;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: Listenable.merge([salon, vm]),
      builder: (context, _) {
        final lista = vm.filtrados;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Clientes'),
            actions: [
              IconButton(
                tooltip: 'Nuevo cliente',
                onPressed: _nuevo,
                icon: const Icon(Icons.person_add_alt_1_outlined),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _nuevo,
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: const Text('Nuevo cliente'),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            itemCount: lista.isEmpty ? 2 : lista.length + 1,
            separatorBuilder: (context, i) => i == 0
                ? const SizedBox.shrink()
                : Divider(height: 1, color: cs.outlineVariant),
            itemBuilder: (context, i) {
              if (i == 0) {
                // Cabecera: búsqueda, filtro y totales.
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SearchBar(
                        controller: _busqueda,
                        hintText: 'Buscar por nombre o teléfono',
                        elevation: const WidgetStatePropertyAll(0),
                        leading: const Icon(Icons.search),
                        trailing: [
                          if (vm.consulta.isNotEmpty)
                            IconButton(
                              tooltip: 'Limpiar',
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _busqueda.clear();
                                vm.setConsulta('');
                              },
                            ),
                        ],
                        onChanged: vm.setConsulta,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<FiltroGenero>(
                          segments: [
                            for (final f in FiltroGenero.values)
                              ButtonSegment(value: f, label: Text(f.etiqueta)),
                          ],
                          selected: {vm.genero},
                          onSelectionChanged: (s) => vm.setGenero(s.first),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${salon.totalClientes} clientes · ${salon.totalMujeres} mujeres · ${salon.totalHombres} hombres',
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                );
              }
              if (lista.isEmpty) {
                return EstadoVacio(
                  icono: Icons.person_search_outlined,
                  titulo: salon.totalClientes == 0
                      ? 'Aún no hay clientes'
                      : 'Sin resultados',
                  mensaje: salon.totalClientes == 0
                      ? 'Registra tu primer cliente con el botón de abajo.'
                      : 'Prueba con otro nombre o teléfono, o cambia el filtro.',
                );
              }
              final c = lista[i - 1];
              final esMujer = c.genero == Genero.mujer;
              final n = salon.cantidadTurnos(c.id);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () => _abrir(c),
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor:
                  esMujer ? cs.primaryContainer : cs.tertiaryContainer,
                  foregroundColor:
                  esMujer ? cs.onPrimaryContainer : cs.onTertiaryContainer,
                  child: Text(inicial(c.nombre),
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ),
                title: Text(c.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleMedium
                        ?.copyWith(fontSize: 15, fontWeight: FontWeight.w600)),
                subtitle: Text(
                    '${telefonoTexto(c.telefono)} · ${c.genero.etiqueta}',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                trailing: Text('$n turno${n == 1 ? '' : 's'}',
                    style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant, fontWeight: FontWeight.w500)),
              );
            },
          ),
        );
      },
    );
  }
}