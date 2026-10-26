
const _dias = [
  'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
];
const _diasCortos = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
const _meses = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto',
  'septiembre', 'octubre', 'noviembre', 'diciembre'
];

DateTime soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);

bool mismoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _dos(int n) => n.toString().padLeft(2, '0');

String horaTexto(DateTime d) => '${_dos(d.hour)}:${_dos(d.minute)}';

String duracionTexto(int min) {
  final h = min ~/ 60;
  final m = min % 60;
  if (h == 0) return '$m min';
  if (m == 0) return '$h h';
  return '$h h $m min';
}

String precioTexto(int v) => '\$ $v';

String diaCorto(DateTime d) => _diasCortos[d.weekday - 1];

String capitalizar(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// "Miércoles 21 de octubre de 2026"
String fechaLarga(DateTime d) =>
    '${_dias[d.weekday - 1]} ${d.day} de ${_meses[d.month - 1]} de ${d.year}';

/// "mié 21 de octubre"
String fechaCorta(DateTime d) =>
    '${diaCorto(d).toLowerCase()} ${d.day} de ${_meses[d.month - 1]}';

/// "Octubre 2026"
String mesAnio(DateTime d) => '${capitalizar(_meses[d.month - 1])} ${d.year}';

String fechaNumerica(DateTime d) => '${_dos(d.day)}/${_dos(d.month)}/${d.year}';

String fechaDiaMes(DateTime d) => '${_dos(d.day)}/${_dos(d.month)}';

/// 52345678 -> "52 345 678"
String telefonoTexto(String t) => t.length == 8
    ? '${t.substring(0, 2)} ${t.substring(2, 5)} ${t.substring(5)}'
    : t;

String inicial(String nombre) =>
    nombre.trim().isEmpty ? '?' : nombre.trim()[0].toUpperCase();

String primerNombre(String nombre) => nombre.trim().split(' ').first;

/// Minúsculas y sin acentos, para búsquedas.
String normalizar(String texto) {
  const origen = 'áàäâéèëêíìïîóòöôúùüûÁÀÄÂÉÈËÊÍÌÏÎÓÒÖÔÚÙÜÛ';
  const destino = 'aaaaeeeeiiiioooouuuuaaaaeeeeiiiioooouuuu';
  final b = StringBuffer();
  for (final c in texto.runes) {
    final ch = String.fromCharCode(c);
    final i = origen.indexOf(ch);
    b.write(i >= 0 ? destino[i] : ch);
  }
  return b.toString().toLowerCase().trim();
}