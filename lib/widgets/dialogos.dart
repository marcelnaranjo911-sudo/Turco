
import 'package:flutter/material.dart';

/// Diálogo de confirmación. Devuelve true si se pulsa el botón de confirmar.
/// (Dialogs y sheets se cierran con Navigator.pop; la prohibición es solo para push/pushNamed.)
Future<bool> confirmar(
    BuildContext context, {
      required String titulo,
      required String mensaje,
      required String textoConfirmar,
      String textoCancelar = 'Volver',
      bool destructivo = false,
      IconData icono = Icons.warning_amber_rounded,
    }) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return AlertDialog(
        icon: Icon(icono, color: destructivo ? cs.error : cs.primary),
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(textoCancelar),
          ),
          TextButton(
            style: destructivo
                ? TextButton.styleFrom(foregroundColor: cs.error)
                : null,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(textoConfirmar),
          ),
        ],
      );
    },
  );
  return resultado ?? false;
}

class OpcionLista<T> {
  const OpcionLista(this.valor, this.texto, [this.detalle]);
  final T valor;
  final String texto;
  final String? detalle;
}

/// Hoja inferior para elegir una opción (cliente o estilista).
Future<T?> elegirOpcion<T>(
    BuildContext context, {
      required String titulo,
      required List<OpcionLista<T>> opciones,
      T? seleccionado,
    }) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: ConstrainedBox(
        constraints:
        BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * .7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(titulo, style: Theme.of(ctx).textTheme.titleMedium),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final o in opciones)
                    ListTile(
                      title: Text(o.texto),
                      subtitle: o.detalle == null ? null : Text(o.detalle!),
                      trailing: o.valor == seleccionado
                          ? Icon(Icons.check,
                          color: Theme.of(ctx).colorScheme.primary)
                          : null,
                      onTap: () => Navigator.of(ctx).pop(o.valor),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}