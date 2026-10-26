
import '../models/cliente.dart';
import '../models/enums.dart';
import '../models/estilista.dart';
import '../models/servicio.dart';
import '../models/turno.dart';

class DatosIniciales {
  DatosIniciales(this.servicios, this.estilistas, this.clientes, this.turnos);
  final List<Servicio> servicios;
  final List<Estilista> estilistas;
  final List<Cliente> clientes;
  final List<Turno> turnos;
}

class SeedData {
  SeedData._();

  static DatosIniciales cargar() {
    final ahora = DateTime.now();

    // ---------------- 12 servicios ----------------
    const servicios = <Servicio>[
      Servicio(id: 1, nombre: 'Corte mujer', categoria: CategoriaServicio.corte, duracionMin: 60, precio: 30, publico: PublicoServicio.mujeres),
      Servicio(id: 2, nombre: 'Corte caballero', categoria: CategoriaServicio.corte, duracionMin: 45, precio: 25, publico: PublicoServicio.hombres),
      Servicio(id: 3, nombre: 'Corte clásico', categoria: CategoriaServicio.corte, duracionMin: 30, precio: 18, publico: PublicoServicio.hombres),
      Servicio(id: 4, nombre: 'Color completo', categoria: CategoriaServicio.color, duracionMin: 120, precio: 70, publico: PublicoServicio.mujeres),
      Servicio(id: 5, nombre: 'Mechas', categoria: CategoriaServicio.color, duracionMin: 90, precio: 60, publico: PublicoServicio.mujeres),
      Servicio(id: 6, nombre: 'Barba', categoria: CategoriaServicio.barba, duracionMin: 45, precio: 20, publico: PublicoServicio.hombres),
      Servicio(id: 7, nombre: 'Afeitado', categoria: CategoriaServicio.barba, duracionMin: 30, precio: 15, publico: PublicoServicio.hombres),
      Servicio(id: 8, nombre: 'Peinado evento', categoria: CategoriaServicio.peinado, duracionMin: 60, precio: 40, publico: PublicoServicio.unisex),
      Servicio(id: 9, nombre: 'Peinado', categoria: CategoriaServicio.peinado, duracionMin: 30, precio: 15, publico: PublicoServicio.unisex),
      Servicio(id: 10, nombre: 'Hidratación', categoria: CategoriaServicio.tratamiento, duracionMin: 45, precio: 28, publico: PublicoServicio.unisex),
      Servicio(id: 11, nombre: 'Keratina', categoria: CategoriaServicio.tratamiento, duracionMin: 90, precio: 55, publico: PublicoServicio.mujeres),
      Servicio(id: 12, nombre: 'Tinte de barba', categoria: CategoriaServicio.color, duracionMin: 45, precio: 22, publico: PublicoServicio.hombres),
    ];
    Servicio s(int id) => servicios.firstWhere((e) => e.id == id);

    // ---------------- 5 estilistas ----------------
    const estilistas = <Estilista>[
      // Solo mujeres
      Estilista(id: 1, nombre: 'Marta Salazar', avatarPath: 'assets/avatars/marta.png', serviciosIds: [1, 4, 5, 11]),
      // Solo hombres
      Estilista(id: 2, nombre: 'Pedro Vega', avatarPath: 'assets/avatars/pedro.png', serviciosIds: [2, 3, 6, 7, 12]),
      // Variados
      Estilista(id: 3, nombre: 'Lucía Torres', avatarPath: 'assets/avatars/lucia.png', serviciosIds: [1, 8, 9, 10, 11]),
      Estilista(id: 4, nombre: 'Rafael Núñez', avatarPath: 'assets/avatars/rafael.png', serviciosIds: [2, 3, 6, 7, 8, 9, 10]),
      // Mujeres y hombres
      Estilista(id: 5, nombre: 'Camila Ortiz', avatarPath: 'assets/avatars/camila.png', serviciosIds: [1, 2, 3, 4, 6, 8, 9, 10]),
    ];

    // ---------------- 10 clientes (5 mujeres, 5 hombres) ----------------
    Cliente c(int id, String nombre, String tel, Genero g, {String? correo}) =>
        Cliente(
          id: id,
          nombre: nombre,
          telefono: tel,
          genero: g,
          correo: correo,
          fechaRegistro: ahora.subtract(Duration(days: 120 - id * 7)),
        );
    final clientes = <Cliente>[
      c(1, 'Laura Gómez', '52111222', Genero.mujer, correo: 'laura.gomez@correo.com'),
      c(2, 'Ana Martín', '53220140', Genero.mujer),
      c(3, 'Sofía Díaz', '54667310', Genero.mujer, correo: 'sofia.diaz@correo.com'),
      c(4, 'Marta Peña', '53441902', Genero.mujer),
      c(5, 'Elena Cruz', '55120987', Genero.mujer),
      c(6, 'Carlos Ruiz', '52345678', Genero.hombre, correo: 'carlos.ruiz@correo.com'),
      c(7, 'Diego Pérez', '55908771', Genero.hombre),
      c(8, 'Javier Soto', '52774009', Genero.hombre), // sin turnos
      c(9, 'Andrés León', '54990321', Genero.hombre),
      c(10, 'Miguel Torres', '53007788', Genero.hombre),
    ];

    // ---------------- 16 turnos ----------------
    // dias[0..6] = 3 días laborables antes, hoy, 3 días laborables después.
    final dias = _semanaLaboral(ahora);
    var idTurno = 1;

    Turno t(
        int dia,
        int h,
        int m,
        int cliente,
        int estilista,
        List<int> svs, {
          String? notas,
          bool anulado = false,
        }) {
      final d = dias[dia];
      final inicio = DateTime(d.year, d.month, d.day, h, m);
      final lista = svs.map(s).toList();
      final fin = inicio
          .add(Duration(minutes: lista.fold(0, (a, e) => a + e.duracionMin)));
      final estado = anulado
          ? EstadoTurno.cancelado
          : (fin.isBefore(ahora)
          ? EstadoTurno.completado
          : EstadoTurno.programado);
      return Turno(
        id: idTurno++,
        clienteId: cliente,
        estilistaId: estilista,
        servicios: lista,
        inicio: inicio,
        notas: notas,
        estado: estado,
        creadoEn: ahora.subtract(const Duration(days: 6)),
        modificadoEn: ahora.subtract(const Duration(days: 5)),
      );
    }

    final notaLarga = ('Prefiere que se use poco calor y productos sin sulfatos. ' * 6).trim();

    final turnos = <Turno>[
      t(0, 9, 0, 1, 1, [1], notas: 'Prefiere agua tibia en el lavado.'),
      t(0, 10, 0, 6, 2, [2, 6], notas: 'Máquina número 2 a los lados.'),
      t(1, 11, 0, 2, 5, [4, 9], notas: 'Quiere un tono cobrizo.'),
      t(1, 14, 0, 7, 4, [6], anulado: true, notas: 'Canceló por viaje.'),
      t(2, 9, 30, 3, 3, [10, 1]), // sin notas
      t(2, 15, 0, 6, 2, [2], notas: 'Corte más corto que la vez anterior.'),
      // Hoy (5 turnos)
      t(3, 9, 0, 1, 1, [1], notas: 'Trae foto de referencia.'),
      t(3, 10, 0, 6, 2, [2, 6],
          notas: 'Prefiere la máquina en el número 2 a los lados. Llega siempre diez minutos antes y pide agua.'),
      t(3, 10, 30, 2, 5, [4, 9], notas: 'Retoque de raíz.'),
      t(3, 12, 0, 7, 2, [6], anulado: true),
      t(3, 14, 0, 3, 3, [10, 1], notas: 'Cabello sensible al calor.'),
      // Futuros
      t(4, 10, 0, 4, 1, [5], notas: notaLarga), // notas > 300 caracteres
      t(4, 11, 0, 9, 4, [2, 6]),
      t(5, 14, 0, 5, 5, [1, 9, 10], notas: 'Tres servicios en una sola visita.'), // 3 servicios
      t(5, 17, 0, 4, 1, [4], notas: 'Evento por la noche.'), // termina 19:00
      t(6, 9, 0, 10, 2, [3, 7]),
    ];

    return DatosIniciales(servicios, estilistas, clientes, turnos);
  }

  /// 7 días laborables (sin domingos): 3 antes, el actual y 3 después.
  /// Si hoy es domingo, el "centro" es el lunes siguiente.
  static List<DateTime> _semanaLaboral(DateTime ahora) {
    var centro = DateTime(ahora.year, ahora.month, ahora.day);
    if (centro.weekday == DateTime.sunday) {
      centro = DateTime(centro.year, centro.month, centro.day + 1);
    }
    DateTime paso(DateTime d, int dir) {
      var n = DateTime(d.year, d.month, d.day + dir);
      if (n.weekday == DateTime.sunday) {
        n = DateTime(n.year, n.month, n.day + dir);
      }
      return n;
    }

    final antes = <DateTime>[];
    var cursor = centro;
    for (var i = 0; i < 3; i++) {
      cursor = paso(cursor, -1);
      antes.insert(0, cursor);
    }
    final despues = <DateTime>[];
    cursor = centro;
    for (var i = 0; i < 3; i++) {
      cursor = paso(cursor, 1);
      despues.add(cursor);
    }
    return [...antes, centro, ...despues];
  }
}