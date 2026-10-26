
import 'package:flutter/foundation.dart';

import '../models/enums.dart';
import '../models/estilista.dart';
import '../models/servicio.dart';
import '../models/turno.dart';
import '../utils/formatters.dart';
import 'salon_view_model.dart';

/// Datos iniciales enviados con `extra` desde otras pantallas.
class TurnoFormInicial {
  const TurnoFormInicial({this.clienteId, this.servicioId, this.fecha});
  final int? clienteId;
  final int? servicioId;
  final DateTime? fecha;
}

/// Valor devuelto con context.pop(...) al guardar.
class TurnoGuardado {
  const TurnoGuardado(
      {required this.id, required this.fecha, required this.esNuevo});
  final int id;
  final DateTime fecha;
  final bool esNuevo;
}

class Franja {
  const Franja(this.minutos, this.disponible);
  final int minutos;
  final bool disponible;

  String get texto =>
      '${(minutos ~/ 60).toString().padLeft(2, '0')}:${(minutos % 60).toString().padLeft(2, '0')}';
}

class TurnoFormViewModel extends ChangeNotifier {
  TurnoFormViewModel(this._salon, {Turno? editar, TurnoFormInicial? inicial})
      : original = editar {
    if (editar != null) {
      clienteId = editar.clienteId;
      serviciosIds.addAll(editar.servicios.map((s) => s.id));
      estilistaId = editar.estilistaId;
      fecha = soloFecha(editar.inicio);
      horaMin = editar.inicio.hour * 60 + editar.inicio.minute;
      notas = editar.notas ?? '';
      final c = _salon.clientePorId(editar.clienteId);
      if (c != null) filtro = FiltroGenero.deGenero(c.genero);
    } else if (inicial != null) {
      final c =
      inicial.clienteId == null ? null : _salon.clientePorId(inicial.clienteId!);
      if (c != null) {
        clienteId = c.id;
        filtro = FiltroGenero.deGenero(c.genero);
      }
      if (inicial.servicioId != null) serviciosIds.add(inicial.servicioId!);
      final f = inicial.fecha;
      if (f != null &&
          f.weekday != DateTime.sunday &&
          !soloFecha(f).isBefore(soloFecha(DateTime.now()))) {
        fecha = soloFecha(f);
      }
    }
    _snapshotInicial = _snapshot();
  }

  final SalonViewModel _salon;
  final Turno? original;

  int? clienteId;
  final Set<int> serviciosIds = {};
  int? estilistaId;
  DateTime? fecha;
  int? horaMin; // minutos desde 00:00
  String notas = '';
  FiltroGenero filtro = FiltroGenero.todos;
  bool mostrarErrores = false;
  late final String _snapshotInicial;

  bool get esEdicion => original != null;

  // ------------------------------------------------------ cálculos derivados
  List<Servicio> get servicios =>
      _salon.servicios.where((s) => serviciosIds.contains(s.id)).toList();
  int get duracionMin => servicios.fold(0, (a, s) => a + s.duracionMin);
  int get total => servicios.fold(0, (a, s) => a + s.precio);
  int get _duracionEfectiva => duracionMin == 0 ? 30 : duracionMin;

  DateTime? get inicio =>
      (fecha == null || horaMin == null) ? null : _inicioDe(horaMin!);
  DateTime? get fin =>
      inicio?.add(Duration(minutes: duracionMin));

  DateTime _inicioDe(int min) =>
      DateTime(fecha!.year, fecha!.month, fecha!.day, min ~/ 60, min % 60);

  bool _permitirPasado(DateTime ini) =>
      original != null && original!.inicio == ini;

  List<Servicio> serviciosVisibles(CategoriaServicio c) => _salon.servicios
      .where((s) =>
  s.categoria == c &&
      (filtro.admiteServicio(s.publico) || serviciosIds.contains(s.id)))
      .toList();

  List<Estilista> get estilistasDisponibles =>
      serviciosIds.isEmpty ? [] : _salon.estilistasPara(serviciosIds);

  List<Franja> get franjas {
    final res = <Franja>[];
    for (var m = SalonViewModel.horaApertura * 60;
    m < SalonViewModel.horaCierre * 60;
    m += SalonViewModel.franjaMin) {
      var ok = false;
      if (fecha != null) {
        final ini = _inicioDe(m);
        ok = _salon.motivoNoDisponible(
          inicio: ini,
          duracionMin: _duracionEfectiva,
          estilistaId: estilistaId,
          clienteId: clienteId,
          ignorarTurnoId: original?.id,
          permitirPasado: _permitirPasado(ini),
        ) ==
            null;
      }
      res.add(Franja(m, ok));
    }
    return res;
  }

  // ---------------------------------------------------------- acciones
  void setCliente(int id) {
    clienteId = id;
    final c = _salon.clientePorId(id);
    if (c != null) filtro = FiltroGenero.deGenero(c.genero); // género por defecto
    _revalidarHora();
    notifyListeners();
  }

  void setFiltro(FiltroGenero f) {
    filtro = f;
    notifyListeners();
  }

  /// Devuelve true si tuvo que limpiar el estilista.
  bool toggleServicio(int id) {
    if (!serviciosIds.remove(id)) serviciosIds.add(id);
    var limpio = false;
    if (estilistaId != null) {
      final e = _salon.estilistaPorId(estilistaId!);
      if (e == null || serviciosIds.isEmpty || !serviciosIds.every(e.realiza)) {
        estilistaId = null;
        limpio = true;
      }
    }
    _revalidarHora();
    notifyListeners();
    return limpio;
  }

  void setEstilista(int id) {
    estilistaId = id;
    _revalidarHora();
    notifyListeners();
  }

  void setFecha(DateTime d) {
    fecha = soloFecha(d);
    _revalidarHora();
    notifyListeners();
  }

  void setHora(int minutos) {
    horaMin = minutos;
    notifyListeners();
  }

  void setNotas(String v) {
    notas = v;
    notifyListeners();
  }

  /// Si la hora elegida deja de estar libre (cambió servicio, estilista o fecha), se limpia.
  void _revalidarHora() {
    if (horaMin == null || fecha == null) return;
    final ini = _inicioDe(horaMin!);
    final motivo = _salon.motivoNoDisponible(
      inicio: ini,
      duracionMin: _duracionEfectiva,
      estilistaId: estilistaId,
      clienteId: clienteId,
      ignorarTurnoId: original?.id,
      permitirPasado: _permitirPasado(ini),
    );
    if (motivo != null) horaMin = null;
  }

  // -------------------------------------------------------- validaciones
  String? get errorCliente =>
      mostrarErrores && clienteId == null ? 'Selecciona un cliente' : null;
  String? get errorServicios =>
      mostrarErrores && serviciosIds.isEmpty ? 'Elige al menos un servicio' : null;
  String? get errorEstilista =>
      mostrarErrores && estilistaId == null ? 'Selecciona un estilista' : null;
  String? get errorFecha {
    if (!mostrarErrores) return null;
    if (fecha == null) return 'Selecciona una fecha';
    if (fecha!.weekday == DateTime.sunday ||
        fecha!.isBefore(soloFecha(DateTime.now()))) {
      return 'Elige una fecha válida (no domingos)';
    }
    return null;
  }

  String? get errorHora =>
      mostrarErrores && horaMin == null ? 'Elige una hora para el turno' : null;

  bool validar() {
    mostrarErrores = true;
    notifyListeners();
    return errorCliente == null &&
        errorServicios == null &&
        errorEstilista == null &&
        errorFecha == null &&
        errorHora == null;
  }

  // ------------------------------------------------------ cambios sin guardar
  String _snapshot() {
    final ids = serviciosIds.toList()..sort();
    return '$clienteId|${ids.join(',')}|$estilistaId|$fecha|$horaMin|$notas';
  }

  bool get hayCambios => _snapshot() != _snapshotInicial;

  ({Turno? turno, String? error}) guardar() => _salon.guardarTurno(
    id: original?.id,
    clienteId: clienteId!,
    estilistaId: estilistaId!,
    servicios: servicios,
    inicio: inicio!,
    notas: notas,
  );
}