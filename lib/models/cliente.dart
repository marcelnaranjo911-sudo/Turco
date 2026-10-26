
import 'enums.dart';

class Cliente {
  const Cliente({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.genero,
    this.correo,
    required this.fechaRegistro,
  });

  final int id;
  final String nombre;
  final String telefono;
  final Genero genero;
  final String? correo;
  final DateTime fechaRegistro;
}