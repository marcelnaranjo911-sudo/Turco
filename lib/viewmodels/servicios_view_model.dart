
import 'package:flutter/foundation.dart';

import '../models/enums.dart';
import '../models/servicio.dart';
import 'salon_view_model.dart';

class ServiciosViewModel extends ChangeNotifier {
  ServiciosViewModel(this._salon);

  final SalonViewModel _salon;
  CategoriaServicio? _categoria; // null = Todas
  FiltroGenero _publico = FiltroGenero.todos;

  CategoriaServicio? get categoria => _categoria;
  FiltroGenero get publico => _publico;

  List<Servicio> get filtrados => _salon.servicios
      .where((s) =>
  (_categoria == null || s.categoria == _categoria) &&
      _publico.admiteServicio(s.publico))
      .toList();

  void setCategoria(CategoriaServicio? c) {
    _categoria = c;
    notifyListeners();
  }

  void setPublico(FiltroGenero p) {
    _publico = p;
    notifyListeners();
  }
}