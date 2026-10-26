
import 'package:flutter/widgets.dart';

import 'viewmodels/agenda_view_model.dart';
import 'viewmodels/clientes_view_model.dart';
import 'viewmodels/salon_view_model.dart';
import 'viewmodels/servicios_view_model.dart';
import 'viewmodels/theme_view_model.dart';

/// Contenedor de ViewModels compartidos por toda la app.
class AppDependencies {
  AppDependencies() {
    salon = SalonViewModel();
    agenda = AgendaViewModel(salon);
    clientes = ClientesViewModel(salon);
    servicios = ServiciosViewModel(salon);
    tema = ThemeViewModel();
  }

  late final SalonViewModel salon;
  late final AgendaViewModel agenda;
  late final ClientesViewModel clientes;
  late final ServiciosViewModel servicios;
  late final ThemeViewModel tema;
}

/// InheritedWidget que expone las dependencias (sin Provider ni similares).
class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.deps, required super.child});

  final AppDependencies deps;

  static AppDependencies of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No hay AppScope en el árbol');
    return scope!.deps;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => deps != oldWidget.deps;
}