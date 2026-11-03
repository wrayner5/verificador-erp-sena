import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/proyecto_provider.dart';
import '../models/verificacion.dart';
import '../models/criterio.dart';

class FormularioScreen extends StatefulWidget {
  const FormularioScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _cargarCriterios(_modeloSeleccionado);
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

  void _guardarVerificacion() {
    if (_formKey.currentState!.validate()) {
      bool faltanObservaciones = _criteriosActuales.any((c) => !c.cumple && c.observacion.trim().length < 15);
      if (faltanObservaciones) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Criterios no cumplidos requieren observación (mínimo 15 caracteres)')),
        );
        return;
      }

      final nueva = Verificacion(
        id: DateTime.now().toString(),
        modelo: _modeloSeleccionado,
        version: int.parse(_versionController.text),
        verificador: _verificadorController.text,
        fecha: DateTime.now(),
        criterios: List.from(_criteriosActuales),
      );

      try {
        Provider.of<ProyectoProvider>(context, listen: false).agregarVerificacion(nueva);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado exitosamente'), backgroundColor: Colors.green));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Verificación')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
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
          ],
        ),
      ),
    );
  }
}
