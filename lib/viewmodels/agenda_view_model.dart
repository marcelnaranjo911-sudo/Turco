
import 'package:flutter/foundation.dart';

import '../models/enums.dart';
import '../models/turno.dart';
import '../utils/formatters.dart';
import 'salon_view_model.dart';

enum FiltroEstado {
  todos,
  programados,
  completados,
  cancelados;

  bool admite(EstadoTurno e) => switch (this) {
    FiltroEstado.todos => true,
    FiltroEstado.programados => e == EstadoTurno.programado,
    FiltroEstado.completados => e == EstadoTurno.completado,
    FiltroEstado.cancelados => e == EstadoTurno.cancelado,
  };
}

class ResumenDia {
  const ResumenDia(this.programados, this.completados, this.ingreso);
  final int programados;
  final int completados;
  final int ingreso;
}

class AgendaViewModel extends ChangeNotifier {
  AgendaViewModel(this._salon) : _fecha = soloFecha(DateTime.now());

  final SalonViewModel _salon;
  DateTime _fecha;
  int? _estilistaId;
  FiltroEstado _estado = FiltroEstado.todos;

  DateTime get fecha => _fecha;
  int? get estilistaId => _estilistaId;
  FiltroEstado get estado => _estado;
  bool get hayFiltros =>
      _estilistaId != null || _estado != FiltroEstado.todos;

  /// Los 7 días (lunes a domingo) de la semana de la fecha seleccionada.
  List<DateTime> get semana {
    final lunes = DateTime(_fecha.year, _fecha.month, _fecha.day - (_fecha.weekday - 1));
    return List.generate(7, (i) => DateTime(lunes.year, lunes.month, lunes.day + i));
  }

  List<Turno> get _delDiaPorEstilista {
    return _salon
        .turnosDelDia(_fecha)
        .where((t) => _estilistaId == null || t.estilistaId == _estilistaId)
        .toList();
  }

  List<Turno> get turnos =>
      _delDiaPorEstilista.where((t) => _estado.admite(t.estado)).toList();

  /// Ingreso estimado = programados + completados (sin cancelados).
  ResumenDia get resumen {
    var prog = 0, comp = 0, ingreso = 0;
    for (final t in _delDiaPorEstilista) {
      if (t.estado == EstadoTurno.programado) {
        prog++;
        ingreso += t.total;
      } else if (t.estado == EstadoTurno.completado) {
        comp++;
        ingreso += t.total;
      }
    }
    return ResumenDia(prog, comp, ingreso);
  }

  void irAFecha(DateTime d) {
    _fecha = soloFecha(d);
    notifyListeners();
  }

  void semanaAnterior() =>
      irAFecha(DateTime(_fecha.year, _fecha.month, _fecha.day - 7));
  void semanaSiguiente() =>
      irAFecha(DateTime(_fecha.year, _fecha.month, _fecha.day + 7));

  void setEstilista(int? id) {
    if (id == _estilistaId) return;
    _estilistaId = id;
    notifyListeners();
  }

  void setEstado(FiltroEstado e) {
    if (e == _estado) return;
    _estado = e;
    notifyListeners();
  }
}