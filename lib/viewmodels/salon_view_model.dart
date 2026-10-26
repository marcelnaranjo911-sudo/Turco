
import 'package:flutter/foundation.dart';

import '../data/seed_data.dart';
import '../models/cliente.dart';
import '../models/enums.dart';
import '../models/estilista.dart';
import '../models/servicio.dart';
import '../models/turno.dart';
import '../utils/formatters.dart';

/// Fuente de verdad en memoria + reglas de negocio del salón.
class SalonViewModel extends ChangeNotifier {
  SalonViewModel() {
    final datos = SeedData.cargar();
    _servicios = datos.servicios;
    _estilistas = datos.estilistas;
    _clientes.addAll(datos.clientes);
    _turnos.addAll(datos.turnos);
    _sigCliente = _clientes.fold(0, (m, c) => c.id > m ? c.id : m) + 1;
    _sigTurno = _turnos.fold(0, (m, t) => t.id > m ? t.id : m) + 1;
  }

  static const int horaApertura = 9;
  static const int horaCierre = 19;
  static const int franjaMin = 30;

  late final List<Servicio> _servicios;
  late final List<Estilista> _estilistas;
  final List<Cliente> _clientes = [];
  final List<Turno> _turnos = [];
  int _sigCliente = 1;
  int _sigTurno = 1;

  // ------------------------------------------------------------ consultas
  List<Servicio> get servicios => List.unmodifiable(_servicios);
  List<Estilista> get estilistas => List.unmodifiable(_estilistas);

  List<Cliente> get clientes {
    final l = [..._clientes];
    l.sort((a, b) => normalizar(a.nombre).compareTo(normalizar(b.nombre)));
    return l;
  }

  int get totalClientes => _clientes.length;
  int get totalMujeres =>
      _clientes.where((c) => c.genero == Genero.mujer).length;
  int get totalHombres =>
      _clientes.where((c) => c.genero == Genero.hombre).length;

  Cliente? clientePorId(int id) {
    for (final c in _clientes) {
      if (c.id == id) return c;
    }
    return null;
  }

  Estilista? estilistaPorId(int id) {
    for (final e in _estilistas) {
      if (e.id == id) return e;
    }
    return null;
  }

  Turno? turnoPorId(int id) {
    for (final t in _turnos) {
      if (t.id == id) return t;
    }
    return null;
  }

  List<Turno> turnosDelDia(DateTime dia) {
    final l = _turnos.where((t) => mismoDia(t.inicio, dia)).toList();
    l.sort((a, b) => a.inicio.compareTo(b.inicio));
    return l;
  }

  List<Turno> turnosDeCliente(int clienteId) {
    final l = _turnos.where((t) => t.clienteId == clienteId).toList();
    l.sort((a, b) => b.inicio.compareTo(a.inicio));
    return l;
  }

  int cantidadTurnos(int clienteId) =>
      _turnos.where((t) => t.clienteId == clienteId).length;

  bool tieneProgramados(int clienteId) => _turnos.any(
          (t) => t.clienteId == clienteId && t.estado == EstadoTurno.programado);

  int programadosDeCliente(int clienteId) => _turnos
      .where((t) =>
  t.clienteId == clienteId && t.estado == EstadoTurno.programado)
      .length;

  int programadosHoy(int estilistaId) {
    final hoy = DateTime.now();
    return _turnos
        .where((t) =>
    t.estilistaId == estilistaId &&
        t.estado == EstadoTurno.programado &&
        mismoDia(t.inicio, hoy))
        .length;
  }

  int get totalProgramadosHoy =>
      _estilistas.fold(0, (a, e) => a + programadosHoy(e.id));

  List<CategoriaServicio> categoriasDe(Estilista e) {
    final set = <CategoriaServicio>{};
    for (final s in _servicios) {
      if (e.realiza(s.id)) set.add(s.categoria);
    }
    return CategoriaServicio.values.where(set.contains).toList();
  }

  /// Estilistas que realizan TODOS los servicios indicados.
  List<Estilista> estilistasPara(Iterable<int> servicioIds) =>
      _estilistas.where((e) => servicioIds.every(e.realiza)).toList();

  // ------------------------------------------------------- reglas de horario
  /// Devuelve el motivo por el que no se puede programar, o null si es válido.
  String? motivoNoDisponible({
    required DateTime inicio,
    required int duracionMin,
    int? estilistaId,
    int? clienteId,
    int? ignorarTurnoId,
    bool permitirPasado = false,
  }) {
    if (inicio.weekday == DateTime.sunday) {
      return 'El salón está cerrado los domingos.';
    }
    final fin = inicio.add(Duration(minutes: duracionMin));
    final apertura =
    DateTime(inicio.year, inicio.month, inicio.day, horaApertura);
    final cierre = DateTime(inicio.year, inicio.month, inicio.day, horaCierre);
    if (inicio.isBefore(apertura) || fin.isAfter(cierre)) {
      return 'El turno debe terminar a las 19:00 como máximo.';
    }
    if (!permitirPasado && inicio.isBefore(DateTime.now())) {
      return 'No se puede programar en una fecha y hora que ya pasaron.';
    }
    for (final t in _turnos) {
      if (!t.ocupaHorario || t.id == ignorarTurnoId) continue;
      if (!t.seSolapaCon(inicio, fin)) continue;
      if (estilistaId != null && t.estilistaId == estilistaId) {
        return 'El estilista ya tiene un turno en ese horario.';
      }
      if (clienteId != null && t.clienteId == clienteId) {
        return 'El cliente ya tiene un turno en ese horario.';
      }
    }
    return null;
  }

  // ------------------------------------------------------------- turnos
  ({Turno? turno, String? error}) guardarTurno({
    int? id,
    required int clienteId,
    required int estilistaId,
    required List<Servicio> servicios,
    required DateTime inicio,
    String? notas,
  }) {
    if (servicios.isEmpty) {
      return (turno: null, error: 'Elige al menos un servicio.');
    }
    final estilista = estilistaPorId(estilistaId);
    if (estilista == null || !servicios.every((s) => estilista.realiza(s.id))) {
      return (
      turno: null,
      error: 'El estilista no realiza todos los servicios elegidos.'
      );
    }
    final original = id == null ? null : turnoPorId(id);
    if (id != null &&
        (original == null || original.estado != EstadoTurno.programado)) {
      return (turno: null, error: 'Solo se pueden editar turnos programados.');
    }
    final duracion = servicios.fold(0, (a, s) => a + s.duracionMin);
    final motivo = motivoNoDisponible(
      inicio: inicio,
      duracionMin: duracion,
      estilistaId: estilistaId,
      clienteId: clienteId,
      ignorarTurnoId: id,
      permitirPasado: original != null && original.inicio == inicio,
    );
    if (motivo != null) return (turno: null, error: motivo);

    final ahora = DateTime.now();
    final limpias = notas?.trim();
    final notasFinal = (limpias == null || limpias.isEmpty) ? null : limpias;

    final Turno resultado;
    if (original == null) {
      resultado = Turno(
        id: _sigTurno++,
        clienteId: clienteId,
        estilistaId: estilistaId,
        servicios: servicios,
        inicio: inicio,
        notas: notasFinal,
        estado: EstadoTurno.programado,
        creadoEn: ahora,
        modificadoEn: ahora,
      );
      _turnos.add(resultado);
    } else {
      resultado = Turno(
        id: original.id,
        clienteId: clienteId,
        estilistaId: estilistaId,
        servicios: servicios,
        inicio: inicio,
        notas: notasFinal,
        estado: EstadoTurno.programado,
        creadoEn: original.creadoEn,
        modificadoEn: ahora,
      );
      _turnos[_turnos.indexWhere((t) => t.id == original.id)] = resultado;
    }
    notifyListeners();
    return (turno: resultado, error: null);
  }

  void completar(int id) => _cambiarEstado(id, EstadoTurno.completado);
  void cancelar(int id) => _cambiarEstado(id, EstadoTurno.cancelado);

  void _cambiarEstado(int id, EstadoTurno nuevo) {
    final i = _turnos.indexWhere((t) => t.id == id);
    if (i < 0 || _turnos[i].estado != EstadoTurno.programado) return;
    _turnos[i] =
        _turnos[i].copyWith(estado: nuevo, modificadoEn: DateTime.now());
    notifyListeners();
  }

  // ------------------------------------------------------------ clientes
  String? validarTelefono(String telefono, {int? ignorarClienteId}) {
    final repetido =
    _clientes.any((c) => c.telefono == telefono && c.id != ignorarClienteId);
    return repetido ? 'Este teléfono ya está registrado' : null;
  }

  Cliente crearCliente({
    required String nombre,
    required String telefono,
    required Genero genero,
    String? correo,
  }) {
    final c = Cliente(
      id: _sigCliente++,
      nombre: nombre.trim(),
      telefono: telefono,
      genero: genero,
      correo: (correo == null || correo.trim().isEmpty) ? null : correo.trim(),
      fechaRegistro: DateTime.now(),
    );
    _clientes.add(c);
    notifyListeners();
    return c;
  }

  Cliente actualizarCliente({
    required int id,
    required String nombre,
    required String telefono,
    required Genero genero,
    String? correo,
  }) {
    final i = _clientes.indexWhere((c) => c.id == id);
    final c = Cliente(
      id: id,
      nombre: nombre.trim(),
      telefono: telefono,
      genero: genero,
      correo: (correo == null || correo.trim().isEmpty) ? null : correo.trim(),
      fechaRegistro: _clientes[i].fechaRegistro,
    );
    _clientes[i] = c;
    notifyListeners();
    return c;
  }

  /// Elimina al cliente y su historial. Debe llamarse solo si no tiene programados.
  bool eliminarCliente(int id) {
    if (tieneProgramados(id)) return false;
    _turnos.removeWhere((t) => t.clienteId == id);
    _clientes.removeWhere((c) => c.id == id);
    notifyListeners();
    return true;
  }
}