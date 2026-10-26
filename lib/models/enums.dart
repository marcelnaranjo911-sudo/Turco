
import 'package:flutter/material.dart';

enum CategoriaServicio {
  corte,
  color,
  barba,
  peinado,
  tratamiento;

  String get etiqueta => switch (this) {
    CategoriaServicio.corte => 'Corte',
    CategoriaServicio.color => 'Color',
    CategoriaServicio.barba => 'Barba',
    CategoriaServicio.peinado => 'Peinado',
    CategoriaServicio.tratamiento => 'Tratamiento',
  };

  IconData get icono => switch (this) {
    CategoriaServicio.corte => Icons.content_cut,
    CategoriaServicio.color => Icons.palette_outlined,
    CategoriaServicio.barba => Icons.face_retouching_natural,
    CategoriaServicio.peinado => Icons.auto_fix_high,
    CategoriaServicio.tratamiento => Icons.water_drop_outlined,
  };
}

enum PublicoServicio {
  mujeres,
  hombres,
  unisex;

  String get etiqueta => switch (this) {
    PublicoServicio.mujeres => 'Mujeres',
    PublicoServicio.hombres => 'Hombres',
    PublicoServicio.unisex => 'Unisex',
  };
}

enum Genero {
  mujer,
  hombre;

  String get etiqueta => this == Genero.mujer ? 'Mujer' : 'Hombre';
}

enum EstadoTurno {
  programado,
  completado,
  cancelado;

  String get etiqueta => switch (this) {
    EstadoTurno.programado => 'Programado',
    EstadoTurno.completado => 'Completado',
    EstadoTurno.cancelado => 'Cancelado',
  };
}

/// Filtro Todos / Mujeres / Hombres usado en Clientes, Servicios y Formulario.
enum FiltroGenero {
  todos,
  mujeres,
  hombres;

  String get etiqueta => switch (this) {
    FiltroGenero.todos => 'Todos',
    FiltroGenero.mujeres => 'Mujeres',
    FiltroGenero.hombres => 'Hombres',
  };

  bool admiteCliente(Genero g) =>
      this == FiltroGenero.todos ||
          (this == FiltroGenero.mujeres && g == Genero.mujer) ||
          (this == FiltroGenero.hombres && g == Genero.hombre);

  /// Los servicios unisex aparecen en cualquier filtro.
  bool admiteServicio(PublicoServicio p) =>
      this == FiltroGenero.todos ||
          p == PublicoServicio.unisex ||
          (this == FiltroGenero.mujeres && p == PublicoServicio.mujeres) ||
          (this == FiltroGenero.hombres && p == PublicoServicio.hombres);

  static FiltroGenero deGenero(Genero g) =>
      g == Genero.mujer ? FiltroGenero.mujeres : FiltroGenero.hombres;
}