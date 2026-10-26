
import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/enums.dart';
import '../utils/formatters.dart';
import 'componentes.dart';

enum AccionCliente { nuevoTurno, editar, eliminar }

/// Hoja con datos e historial del cliente. Devuelve la acción elegida.
Future<AccionCliente?> mostrarDetalleCliente(
    BuildContext context, int clienteId) {
  return showModalBottomSheet<AccionCliente>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (ctx) => _ClienteDetalleSheet(clienteId: clienteId),
  );
}

class _ClienteDetalleSheet extends StatelessWidget {
  const _ClienteDetalleSheet({required this.clienteId});
  final int clienteId;

  @override
  Widget build(BuildContext context) {
    final salon = AppScope.of(context).salon;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: salon,
      builder: (context, _) {
        final c = salon.clientePorId(clienteId);
        if (c == null) return const SizedBox.shrink();
        final historial = salon.turnosDeCliente(c.id);
        final esMujer = c.genero == Genero.mujer;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                      esMujer ? cs.primaryContainer : cs.tertiaryContainer,
                      foregroundColor: esMujer
                          ? cs.onPrimaryContainer
                          : cs.onTertiaryContainer,
                      child: Text(inicial(c.nombre),
                          style: tt.titleMedium?.copyWith(
                              fontSize: 22, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.nombre,
                              style: tt.titleMedium?.copyWith(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Row(children: [
                            Icon(Icons.phone_outlined,
                                size: 13, color: cs.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(telefonoTexto(c.telefono),
                                style: tt.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant)),
                          ]),
                          if (c.correo != null)
                            Row(children: [
                              Icon(Icons.mail_outline,
                                  size: 13, color: cs.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(c.correo!,
                                    overflow: TextOverflow.ellipsis,
                                    style: tt.bodySmall
                                        ?.copyWith(color: cs.onSurfaceVariant)),
                              ),
                            ]),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Historial de turnos · ${historial.length}',
                    style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if (historial.isEmpty)
                  Text('Este cliente todavía no tiene turnos.',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant))
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 190),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: historial.length,
                      itemBuilder: (context, i) {
                        final t = historial[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${fechaDiaMes(t.inicio)} · ${t.servicios.map((s) => s.nombre).join(' + ')}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: tt.bodySmall,
                                ),
                              ),
                              const SizedBox(width: 8),
                              EstadoBadge(estado: t.estado),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            Navigator.of(context).pop(AccionCliente.nuevoTurno),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Nuevo turno'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pop(AccionCliente.editar),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Editar'),
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      tooltip: 'Eliminar',
                      onPressed: () =>
                          Navigator.of(context).pop(AccionCliente.eliminar),
                      icon: Icon(Icons.delete_outline, color: cs.error),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}