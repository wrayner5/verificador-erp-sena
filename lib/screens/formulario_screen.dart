import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/proyecto_provider.dart';
import '../models/verificacion.dart';
import '../models/criterio.dart';
import '../utils/estado_ui.dart';

class FormularioScreen extends StatefulWidget {
  final Verificacion? editar;
  const FormularioScreen({super.key, this.editar});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _verificadorController = TextEditingController();
  final TextEditingController _versionController = TextEditingController();
  String _modeloSeleccionado = 'Casos de uso';
  List<Criterio> _criteriosActuales = [];
  double _porcentajeActual = 0.0;
  final List<String> _opcionesModelo = ['Casos de uso', 'Clases', 'Secuencia', 'Actividades'];

  bool get _esEdicion => widget.editar != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editar;
    if (e != null) {
      _verificadorController.text = e.verificador;
      _versionController.text = e.version.toString();
      _modeloSeleccionado = e.modelo;
      _criteriosActuales = e.criterios.map((c) {
        final copia = Criterio(
          codigo: c.codigo,
          descripcion: c.descripcion,
          esCritico: c.esCritico,
        );
        copia.cumple = c.cumple;
        copia.observacion = c.observacion;
        return copia;
      }).toList();
      _calcularPorcentajeEnTiempoReal();
    } else {
      _cargarCriterios(_modeloSeleccionado);
    }
  }

  @override
  void dispose() {
    _verificadorController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  void _cargarCriterios(String modelo) {
    if (modelo == 'Casos de uso') {
      _criteriosActuales = [
        Criterio(codigo: 'CU-01', descripcion: 'Admin, cajero y cliente se conectan a casos de uso', esCritico: false),
        Criterio(codigo: 'CU-02', descripcion: 'El cajero tiene conectado el flujo de venta: registro, carrito, pago', esCritico: true),
        Criterio(codigo: 'CU-03', descripcion: 'Existe el caso de uso de turno de caja (apertura y cierre)', esCritico: true),
        Criterio(codigo: 'CU-04', descripcion: 'Las relaciones include y extend son correctas', esCritico: false),
        Criterio(codigo: 'CU-05', descripcion: 'Los módulos con especificación aparecen en el diagrama general', esCritico: false),
        Criterio(codigo: 'CU-06', descripcion: 'El diagrama separa los accesos por rol', esCritico: true),
      ];
    } else if (modelo == 'Clases') {
      _criteriosActuales = [
        Criterio(codigo: 'CL-01', descripcion: 'Administrador, cajero y clientes heredan de usuarios', esCritico: true),
        Criterio(codigo: 'CL-02', descripcion: 'Existe la clase de la venta con código, fecha, total', esCritico: true),
        Criterio(codigo: 'CL-03', descripcion: 'Existen clases para turno de caja y para inventario o mermas', esCritico: false),
        Criterio(codigo: 'CL-04', descripcion: 'Las asociaciones y multiplicidades entre carrito, detalle y pagos son correctas', esCritico: true),
        Criterio(codigo: 'CL-05', descripcion: 'Los métodos de cada clase corresponden a casos de uso', esCritico: false),
        Criterio(codigo: 'CL-06', descripcion: 'La clase unidades productivas describe una unidad (no proveedor)', esCritico: false),
      ];
    } else if (modelo == 'Secuencia') {
      _criteriosActuales = [
        Criterio(codigo: 'SE-01', descripcion: 'Cada diagrama tiene actor, interfaz, lógica y base de datos', esCritico: false),
        Criterio(codigo: 'SE-02', descripcion: 'El proceso de venta valida turno abierto y stock', esCritico: true),
        Criterio(codigo: 'SE-03', descripcion: 'La venta se registra y descuenta inventario solo tras pago', esCritico: true),
        Criterio(codigo: 'SE-04', descripcion: 'Inicio de sesión muestra respuesta y bloqueo tras 3 intentos', esCritico: true),
        Criterio(codigo: 'SE-05', descripcion: 'Validar método de pago muestra confirmación y cancelación', esCritico: false),
        Criterio(codigo: 'SE-06', descripcion: 'Generar reportes muestra filtro, consulta y mensaje vacío', esCritico: false),
      ];
    } else if (modelo == 'Actividades') {
      _criteriosActuales = [
        Criterio(codigo: 'AC-01', descripcion: 'Cada diagrama tiene inicio, final, calles y decisiones', esCritico: false),
        Criterio(codigo: 'AC-02', descripcion: 'El registro de venta incluye validar stock y confirmar pago', esCritico: true),
        Criterio(codigo: 'AC-03', descripcion: 'Medios de pago tiene la rama de pago no confirmado', esCritico: true),
        Criterio(codigo: 'AC-04', descripcion: 'El carrito permite agregar/cambiar/eliminar con alerta sin stock', esCritico: false),
        Criterio(codigo: 'AC-05', descripcion: 'Gestión de categorías/usuarios aplican sus restricciones', esCritico: true),
        Criterio(codigo: 'AC-06', descripcion: 'Reportes y asistencia (horario de almuerzo) están completos', esCritico: false),
      ];
    }
    _calcularPorcentajeEnTiempoReal();
  }

  void _calcularPorcentajeEnTiempoReal() {
    int totales = 0;
    int obtenidos = 0;
    for (var c in _criteriosActuales) {
      int valor = c.esCritico ? 2 : 1;
      totales += valor;
      if (c.cumple) obtenidos += valor;
    }
    setState(() {
      _porcentajeActual = totales == 0 ? 0.0 : (obtenidos / totales) * 100;
    });
  }

  Color _colorPorcentaje() {
    if (_porcentajeActual >= 80) return Colors.green;
    if (_porcentajeActual >= 60) return Colors.orange;
    return Colors.red;
  }

  void _guardarVerificacion() {
    if (!_formKey.currentState!.validate()) {
      mostrarMensaje(context, 'Revise los campos marcados en rojo', error: true);
      return;
    }

    final faltanObservaciones =
        _criteriosActuales.any((c) => !c.cumple && c.observacion.trim().length < 15);
    if (faltanObservaciones) {
      mostrarMensaje(
          context, 'Los criterios no cumplidos requieren una observación de mínimo 15 caracteres',
          error: true);
      return;
    }

    final nueva = Verificacion(
      id: _esEdicion ? widget.editar!.id : DateTime.now().toString(),
      modelo: _modeloSeleccionado,
      version: int.parse(_versionController.text),
      verificador: _verificadorController.text,
      fecha: DateTime.now(),
      criterios: List.from(_criteriosActuales),
    );

    try {
      final provider = Provider.of<ProyectoProvider>(context, listen: false);
      if (_esEdicion) {
        provider.editarVerificacion(nueva);
        mostrarMensaje(context, 'Verificación actualizada correctamente');
      } else {
        provider.agregarVerificacion(nueva);
        mostrarMensaje(context, 'Verificación guardada correctamente');
      }
      Navigator.pop(context);
    } catch (e) {
      mostrarMensaje(context, limpiarError(e), error: true);
    }
  }

  Widget _seccion(String titulo, IconData icono, List<Widget> hijos) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD
            TextFormField(
              controller: _verificadorController,
              decoration: const InputDecoration(labelText: 'Verificador', border: OutlineInputBorder()),
              validator: (v) => v!.trim().length < 3 ? 'Mínimo 3 letras' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _versionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Versión', border: OutlineInputBorder()),
              validator: (v) => (int.tryParse(v ?? '') ?? 0) < 1 ? 'Mayor o igual a 1' : null,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _modeloSeleccionado,
              decoration: const InputDecoration(labelText: 'Modelo', border: OutlineInputBorder()),
              items: _opcionesModelo.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (v) {
                if (v != null) setState(() { _modeloSeleccionado = v; _cargarCriterios(v); });
              },
            ),
            const Divider(height: 30, thickness: 2),
            Text('Cumplimiento: ${_porcentajeActual.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16, color: Colors.blue)),
            ..._criteriosActuales.map((c) {
              return Card(
                color: c.esCritico ? Colors.red.shade50 : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: Text('${c.codigo}: ${c.descripcion}'),
                        subtitle: c.esCritico ? const Text('CRÍTICO', style: TextStyle(color: Colors.red)) : const Text('Normal'),
                        value: c.cumple,
                        onChanged: (v) => setState(() { c.cumple = v ?? false; _calcularPorcentajeEnTiempoReal(); }),
                      ),
                      if (!c.cumple)
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Observación (Obligatoria si no cumple)'),
                          onChanged: (v) => c.observacion = v,
                        ),
                    ],
                  ),
                ),
              );
            }),
            ElevatedButton(onPressed: _guardarVerificacion, child: const Text('Guardar'))
=======
            Row(children: [
              Icon(icono, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ]),
            const Divider(height: 24),
            ...hijos,
>>>>>>> de41cf4d7e8a4b69860d0201b8b7e5124f0b2a17
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final incumplidos = _criteriosActuales.where((c) => !c.cumple).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar Verificación' : 'Nueva Verificación'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            _seccion('1. Datos de la verificación', Icons.assignment, [
              TextFormField(
                controller: _verificadorController,
                decoration: const InputDecoration(labelText: 'Verificador', border: OutlineInputBorder()),
                validator: (v) => (v ?? '').trim().length < 3 ? 'Mínimo 3 letras' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _versionController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Versión', border: OutlineInputBorder()),
                validator: (v) => (int.tryParse(v ?? '') ?? 0) < 1 ? 'Mayor o igual a 1' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _modeloSeleccionado,
                decoration: const InputDecoration(labelText: 'Modelo', border: OutlineInputBorder()),
                items: _opcionesModelo
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                // Al editar no se permite cambiar de modelo
                onChanged: _esEdicion
                    ? null
                    : (v) {
                        if (v != null) {
                          setState(() {
                            _modeloSeleccionado = v;
                            _cargarCriterios(v);
                          });
                        }
                      },
              ),
            ]),

            _seccion('2. Criterios', Icons.checklist, [
              Text('Cumplimiento: ${_porcentajeActual.toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _colorPorcentaje())),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _porcentajeActual / 100,
                minHeight: 10,
                color: _colorPorcentaje(),
                backgroundColor: Colors.grey.shade300,
              ),
              const SizedBox(height: 12),
              ..._criteriosActuales.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  // Material en lugar de Container: evita el aviso del ListTile
                  child: Material(
                    color: c.esCritico ? Colors.red.shade50 : Colors.grey.shade50,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: c.esCritico ? Colors.red : Colors.grey.shade300,
                        width: c.esCritico ? 1.5 : 1,
                      ),
                    ),
                    child: CheckboxListTile(
                      secondary: Icon(
                        c.esCritico ? Icons.priority_high : Icons.circle_outlined,
                        color: c.esCritico ? Colors.red : Colors.grey,
                      ),
                      title: Text('${c.codigo}: ${c.descripcion}'),
                      subtitle: c.esCritico
                          ? const Align(
                              alignment: Alignment.centerLeft,
                              child: Chip(
                                visualDensity: VisualDensity.compact,
                                label: Text('CRÍTICO',
                                    style: TextStyle(color: Colors.white, fontSize: 11)),
                                backgroundColor: Colors.red,
                              ),
                            )
                          : const Text('Normal'),
                      value: c.cumple,
                      onChanged: (v) => setState(() {
                        c.cumple = v ?? false;
                        _calcularPorcentajeEnTiempoReal();
                      }),
                    ),
                  ),
                );
              }),
            ]),

            // SECCIÓN 3: observaciones
            _seccion('3. Observaciones', Icons.notes, [
              if (incumplidos.isEmpty)
                const Text('Todos los criterios cumplen. No hay observaciones pendientes.')
              else
                ...incumplidos.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextFormField(
                        key: ValueKey('obs_${c.codigo}'),
                        initialValue: c.observacion,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: '${c.codigo}: observación (mínimo 15 caracteres)',
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(
                            c.esCritico ? Icons.priority_high : Icons.edit_note,
                            color: c.esCritico ? Colors.red : null,
                          ),
                        ),
                        onChanged: (v) => c.observacion = v,
                        validator: (v) => (v ?? '').trim().length < 15
                            ? 'Describa por qué no cumple (mínimo 15 caracteres)'
                            : null,
                      ),
                    )),
            ]),

            FilledButton.icon(
              onPressed: _guardarVerificacion,
              icon: const Icon(Icons.save),
              label: Text(_esEdicion ? 'Guardar cambios' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}