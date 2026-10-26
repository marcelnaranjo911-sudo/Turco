
import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/estilista.dart';
import '../utils/formatters.dart';

/// Color asociado a cada estado (barra lateral de la tarjeta).
Color colorEstado(BuildContext context, EstadoTurno e) {
  final cs = Theme.of(context).colorScheme;
  return switch (e) {
    EstadoTurno.programado => cs.primary,
    EstadoTurno.completado => cs.tertiary,
    EstadoTurno.cancelado => cs.error,
  };
}

class EstadoBadge extends StatelessWidget {
  const EstadoBadge({super.key, required this.estado});
  final EstadoTurno estado;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (fondo, texto) = switch (estado) {
      EstadoTurno.programado => (cs.primaryContainer, cs.onPrimaryContainer),
      EstadoTurno.completado => (cs.tertiaryContainer, cs.onTertiaryContainer),
      EstadoTurno.cancelado => (cs.errorContainer, cs.onErrorContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        estado.etiqueta,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: texto, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Mensaje con ilustración para listas vacías o pantallas de error.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    required this.mensaje,
    this.esError = false,
    this.accion,
  });

  final IconData icono;
  final String titulo;
  final String mensaje;
  final bool esError;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: esError ? cs.errorContainer : cs.primaryContainer,
                ),
                child: Icon(icono,
                    size: 52, color: esError ? cs.error : cs.primary),
              ),
              const SizedBox(height: 14),
              Text(titulo,
                  textAlign: TextAlign.center,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(mensaje,
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              if (accion != null) ...[const SizedBox(height: 16), accion!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Texto de error con icono (bajo servicios u hora).
class ErrorTexto extends StatelessWidget {
  const ErrorTexto(this.texto, {super.key});
  final String texto;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 14, color: cs.error),
          const SizedBox(width: 6),
          Expanded(
            child: Text(texto,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: cs.error)),
          ),
        ],
      ),
    );
  }
}

/// Campo "tocable" con aspecto de input (cliente, estilista, fecha).
class CampoToque extends StatelessWidget {
  const CampoToque({
    super.key,
    required this.etiqueta,
    required this.icono,
    required this.hint,
    required this.onTap,
    this.texto,
    this.errorText,
    this.focusNode,
  });

  final String etiqueta;
  final IconData icono;
  final String hint;
  final String? texto;
  final String? errorText;
  final FocusNode? focusNode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Focus(
      focusNode: focusNode,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: InputDecorator(
          isEmpty: texto == null,
          decoration: InputDecoration(
            labelText: etiqueta,
            hintText: hint,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            prefixIcon: Icon(icono),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            errorText: errorText,
          ),
          child: Text(
            texto ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: cs.onSurface),
          ),
        ),
      ),
    );
  }
}

class AvatarEstilista extends StatelessWidget {
  const AvatarEstilista({super.key, required this.estilista, this.radio = 28});
  final Estilista estilista;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radio,
      backgroundColor: cs.primaryContainer,
      foregroundColor: cs.onPrimaryContainer,
      foregroundImage: AssetImage(estilista.avatarPath),
      onForegroundImageError: (_, __) {}, // si falta la imagen se ve la inicial
      child: Text(inicial(estilista.nombre),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontSize: radio * .8, fontWeight: FontWeight.w600)),
    );
  }
}