
import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/turno.dart';
import '../utils/formatters.dart';
import 'componentes.dart';

class TurnoCard extends StatelessWidget {
  const TurnoCard({
    super.key,
    required this.turno,
    required this.clienteNombre,
    required this.estilistaNombre,
    required this.onTap,
    this.onLongPress,
  });

  final Turno turno;
  final String clienteNombre;
  final String estilistaNombre;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Opacity(
      opacity: turno.estado == EstadoTurno.cancelado ? .75 : 1,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  margin: const EdgeInsets.fromLTRB(10, 12, 0, 12),
                  decoration: BoxDecoration(
                    color: colorEstado(context, turno.estado),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 12, 0, 12),
                  child: SizedBox(
                    width: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(horaTexto(turno.inicio),
                            style: tt.titleMedium?.copyWith(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(horaTexto(turno.fin),
                            style: tt.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(clienteNombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.titleMedium?.copyWith(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(turno.servicios.map((s) => s.nombre).join(' + '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: tt.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.person_outline,
                                size: 14, color: cs.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(estilistaNombre,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: tt.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      fontWeight: FontWeight.w500)),
                            ),
                            const SizedBox(width: 8),
                            EstadoBadge(estado: turno.estado),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}