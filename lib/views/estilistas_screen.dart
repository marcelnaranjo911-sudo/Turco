
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_scope.dart';
import '../models/estilista.dart';
import '../viewmodels/salon_view_model.dart';
import '../widgets/componentes.dart';

class EstilistasScreen extends StatelessWidget {
  const EstilistasScreen({super.key});

  void _abrirAgenda(BuildContext context, Estilista e) {
    final deps = AppScope.of(context);
    deps.agenda.setEstilista(e.id);
    // El identificador viaja como parámetro de consulta: /agenda?estilista=ID
    context.go(Uri(
      path: '/agenda',
      queryParameters: {'estilista': '${e.id}'},
    ).toString());
  }

  @override
  Widget build(BuildContext context) {
    final salon = AppScope.of(context).salon;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: salon,
      builder: (context, _) {
        final estilistas = salon.estilistas;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 170,
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                surfaceTintColor: cs.primary,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                  const EdgeInsetsDirectional.only(start: 20, bottom: 36),
                  title: Text('Estilistas',
                      style: tt.titleLarge?.copyWith(
                          color: cs.onPrimary, fontWeight: FontWeight.w600)),
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.badge_outlined,
                              size: 28, color: cs.onPrimary),
                          const SizedBox(height: 50),
                          Text(
                            '${estilistas.length} profesionales · ${salon.totalProgramadosHoy} turnos programados hoy',
                            style: tt.bodySmall?.copyWith(
                                color: cs.onPrimary.withValues(alpha: .85)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _EstilistaCard(
                        estilista: estilistas[i],
                        salon: salon,
                        onTap: () => _abrirAgenda(context, estilistas[i]),
                      ),
                    ),
                    childCount: estilistas.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EstilistaCard extends StatelessWidget {
  const _EstilistaCard(
      {required this.estilista, required this.salon, required this.onTap});
  final Estilista estilista;
  final SalonViewModel salon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hoy = salon.programadosHoy(estilista.id);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              AvatarEstilista(estilista: estilista),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(estilista.nombre,
                        style: tt.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    // Servicios que realiza, agrupados por categoría.
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final c in salon.categoriasDe(estilista))
                          Chip(
                            label: Text(c.etiqueta),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hoy == 0
                          ? 'Sin turnos hoy'
                          : '$hoy turno${hoy == 1 ? '' : 's'} hoy',
                      style: tt.bodySmall?.copyWith(
                          color: hoy == 0 ? cs.onSurfaceVariant : cs.primary,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}