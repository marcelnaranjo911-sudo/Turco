
import 'package:flutter/foundation.dart';

import '../models/cliente.dart';
import '../models/enums.dart';
import '../utils/formatters.dart';
import 'salon_view_model.dart';

class ClientesViewModel extends ChangeNotifier {
  ClientesViewModel(this._salon);

  final SalonViewModel _salon;
  String _consulta = '';
  FiltroGenero _genero = FiltroGenero.todos;

  String get consulta => _consulta;
  FiltroGenero get genero => _genero;

  /// Búsqueda por nombre o teléfono (sin mayúsculas ni acentos) + filtro de género.
  List<Cliente> get filtrados {
    final q = normalizar(_consulta);
    final digitos = _consulta.replaceAll(RegExp(r'\D'), '');
    return _salon.clientes.where((c) {
      if (!_genero.admiteCliente(c.genero)) return false;
      if (q.isEmpty) return true;
      final porNombre = normalizar(c.nombre).contains(q);
      final porTelefono = digitos.isNotEmpty && c.telefono.contains(digitos);
      return porNombre || porTelefono;
    }).toList();
  }

  void setConsulta(String v) {
    _consulta = v;
    notifyListeners();
  }

  void setGenero(FiltroGenero g) {
    if (g == _genero) return;
    _genero = g;
    notifyListeners();
  }
}