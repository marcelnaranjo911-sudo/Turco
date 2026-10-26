
class Estilista {
  const Estilista({
    required this.id,
    required this.nombre,
    required this.avatarPath,
    required this.serviciosIds,
  });

  final int id;
  final String nombre;
  final String avatarPath;
  final List<int> serviciosIds;

  bool realiza(int servicioId) => serviciosIds.contains(servicioId);
}