
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../models/cliente.dart';
import '../models/enums.dart';
import 'componentes.dart';

/// Hoja inferior de alta/edición de cliente. Se reutiliza en Clientes y en el
/// formulario de turno. Devuelve el cliente guardado (o null si se cancela).
Future<Cliente?> mostrarFormularioCliente(BuildContext context,
    {Cliente? cliente}) {
  return showModalBottomSheet<Cliente>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (ctx) => ClienteFormSheet(cliente: cliente),
  );
}

class ClienteFormSheet extends StatefulWidget {
  const ClienteFormSheet({super.key, this.cliente});
  final Cliente? cliente;

  @override
  State<ClienteFormSheet> createState() => _ClienteFormSheetState();
}

class _ClienteFormSheetState extends State<ClienteFormSheet> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _telefono;
  late final TextEditingController _correo;
  final _fNombre = FocusNode();
  final _fTelefono = FocusNode();
  final _fCorreo = FocusNode();
  Genero? _genero;
  bool _errorGenero = false;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;
    _nombre = TextEditingController(text: c?.nombre ?? '');
    _telefono = TextEditingController(text: c?.telefono ?? '');
    _correo = TextEditingController(text: c?.correo ?? '');
    _genero = c?.genero;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _correo.dispose();
    _fNombre.dispose();
    _fTelefono.dispose();
    _fCorreo.dispose();
    super.dispose();
  }

  String? _vNombre(String? v) {
    final t = (v ?? '').trim();
    if (t.length < 3 || t.length > 60) return 'Escribe entre 3 y 60 caracteres';
    return null;
  }

  String? _vTelefono(String? v) {
    final t = (v ?? '').trim();
    if (!RegExp(r'^\d{8}$').hasMatch(t)) {
      return 'Debe tener exactamente 8 dígitos';
    }
    return AppScope.of(context)
        .salon
        .validarTelefono(t, ignorarClienteId: widget.cliente?.id);
  }

  String? _vCorreo(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null;
    final ok = RegExp(r'^[\w.+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)+$')
        .hasMatch(t);
    return ok ? null : 'Escribe un correo válido';
  }

  void _guardar() {
    final formOk = _form.currentState!.validate();
    final generoOk = _genero != null;
    setState(() => _errorGenero = !generoOk);
    if (!formOk || !generoOk) {
      // El foco va al primer campo con error.
      if (_vNombre(_nombre.text) != null) {
        _fNombre.requestFocus();
      } else if (_vTelefono(_telefono.text) != null) {
        _fTelefono.requestFocus();
      } else if (_vCorreo(_correo.text) != null) {
        _fCorreo.requestFocus();
      }
      return;
    }
    final salon = AppScope.of(context).salon;
    final c = widget.cliente;
    final guardado = c == null
        ? salon.crearCliente(
        nombre: _nombre.text,
        telefono: _telefono.text.trim(),
        genero: _genero!,
        correo: _correo.text)
        : salon.actualizarCliente(
        id: c.id,
        nombre: _nombre.text,
        telefono: _telefono.text.trim(),
        genero: _genero!,
        correo: _correo.text);
    Navigator.of(context).pop(guardado);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.cliente == null ? 'Nuevo cliente' : 'Editar cliente',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nombre,
                focusNode: _fNombre,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                onFieldSubmitted: (_) => _fTelefono.requestFocus(),
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: _vNombre,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _telefono,
                focusNode: _fTelefono,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onFieldSubmitted: (_) => _fCorreo.requestFocus(),
                decoration: const InputDecoration(labelText: 'Teléfono'),
                validator: _vTelefono,
              ),
              const SizedBox(height: 14),
              Text('Género',
                  style: tt.labelLarge?.copyWith(
                      color: _errorGenero ? cs.error : cs.onSurfaceVariant)),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<Genero>(
                  emptySelectionAllowed: true,
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: Genero.mujer, label: Text('Mujer')),
                    ButtonSegment(value: Genero.hombre, label: Text('Hombre')),
                  ],
                  selected: _genero == null ? <Genero>{} : {_genero!},
                  onSelectionChanged: (s) => setState(() {
                    _genero = s.isEmpty ? null : s.first;
                    _errorGenero = false;
                  }),
                ),
              ),
              if (_errorGenero) const ErrorTexto('Selecciona un género'),
              const SizedBox(height: 14),
              TextFormField(
                controller: _correo,
                focusNode: _fCorreo,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _guardar(),
                decoration: const InputDecoration(labelText: 'Correo (opcional)'),
                validator: _vCorreo,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _guardar,
                      child: const Text('Guardar cliente'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}