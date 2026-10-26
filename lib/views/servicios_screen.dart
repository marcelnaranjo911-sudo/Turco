
import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/enums.dart';
import '../models/servicio.dart';
import '../utils/navegacion.dart';
import '../viewmodels/servicios_view_model.dart';
import '../viewmodels/turno_form_view_model.dart';
import '../widgets/componentes.dart';

class ServiciosScreen extends StatelessWidget {
  const ServiciosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    final vm = deps.servicios;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final lista = vm.filtrados;
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 64,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Servicios'),
                Text('Toca un servicio para reservar',
                    style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant, fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('Todas'),
                          selected: vm.categoria == null,
                          onSelected: (_) => vm.setCategoria(null),
                        ),
                      ),
                      for (final c in CategoriaServicio.values)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(c.etiqueta),
                            selected: vm.categoria == c,
                            onSelected: (_) => vm.setCategoria(c),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<FiltroGenero>(
                    segments: [
                      for (final f in FiltroGenero.values)
                        ButtonSegment(value: f, label: Text(f.etiqueta)),
                    ],
                    selected: {vm.publico},
                    onSelectionChanged: (s) => vm.setPublico(s.first),
                  ),
                ),
                const SizedBox(height: 12),
                if (lista.isEmpty)
                  const EstadoVacio(
                    icono: Icons.search_off,
                    titulo: 'No hay servicios',
                    mensaje: 'Ningún servicio coincide con los filtros elegidos.',
                  )
                else
                  LayoutBuilder(
                    builder: (context, c) {
                      // 2 columnas < 600dp, 3 entre 600 y 840, 4 desde 840.
                      final ancho = MediaQuery.sizeOf(context).width;
                      final columnas = ancho < 600 ? 2 : (ancho < 840 ? 3 : 4);
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: lista.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columnas,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: .82,
                        ),
                        itemBuilder: (context, i) => _ServicioCard(
                          servicio: lista[i],
                          onTap: () => abrirFormularioTurno(
                            context,
                            inicial: TurnoFormInicial(
                                servicioId: lista[i].id,
                                fecha: deps.agenda.fecha),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ServicioCard extends StatelessWidget {
  const _ServicioCard({required this.servicio, required this.onTap});
  final Servicio servicio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cat = servicio.categoria;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  // Imagen propia de la categoría; si falta, se muestra el icono.
                  child: Image.asset(
                    'assets/images/${cat.name}.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Center(child: Icon(cat.icono, size: 36, color: cs.primary)),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(servicio.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleMedium
                      ?.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.schedule, size: 12, color: cs.onSurfaceVariant),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text('${servicio.duracionMin} min',
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ),
                  Text('\$ ${servicio.precio}',
                      style: tt.bodySmall?.copyWith(
                          color: cs.primary, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(servicio.publico.etiqueta,
                    style: tt.labelSmall?.copyWith(
                        color: cs.onSecondaryContainer,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}