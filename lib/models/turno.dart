
import 'enums.dart';
import 'servicio.dart';

class Turno {
  const Turno({
    required this.id,
    required this.clienteId,
    required this.estilistaId,
    required this.servicios,
    required this.inicio,
    this.notas,
    required this.estado,
    required this.creadoEn,
    required this.modificadoEn,
  });

  final int id;
  final int clienteId;
  final int estilistaId;
  final List<Servicio> servicios;
  final DateTime inicio;
  final String? notas;
  final EstadoTurno estado;
  final DateTime creadoEn;
  final DateTime modificadoEn;

  // Valores calculados: no se guardan.
  int get duracionMin => servicios.fold(0, (a, s) => a + s.duracionMin);
  int get total => servicios.fold(0, (a, s) => a + s.precio);
  DateTime get fin => inicio.add(Duration(minutes: duracionMin));

  /// Los cancelados no ocupan horario.
  bool get ocupaHorario => estado != EstadoTurno.cancelado;

  /// Un turno que termina a las 10:00 no se solapa con uno que empieza a las 10:00.
  bool seSolapaCon(DateTime desde, DateTime hasta) =>
      inicio.isBefore(hasta) && desde.isBefore(fin);

  Turno copyWith({EstadoTurno? estado, DateTime? modificadoEn}) => Turno(
    id: id,
    clienteId: clienteId,
    estilistaId: estilistaId,
    servicios: servicios,
    inicio: inicio,
    notas: notas,
    estado: estado ?? this.estado,
    creadoEn: creadoEn,
    modificadoEn: modificadoEn ?? this.modificadoEn,
  );
}