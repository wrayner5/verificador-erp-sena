import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/verificacion.dart';
import '../providers/proyecto_provider.dart';
import '../utils/estado_ui.dart';
import 'formulario_screen.dart';
import 'reporte_screen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  String _busqueda = '';
  String? _filtroEstado; // null = todos

  Future<void> _confirmarEliminar(BuildContext context, String id, String nombre) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar verificación'),
        content: Text('¿Seguro que desea eliminar "$nombre"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      try {
        context.read<ProyectoProvider>().eliminarVerificacion(id);
        mostrarMensaje(context, 'Verificación eliminada correctamente');
      } catch (e) {
        mostrarMensaje(context, limpiarError(e), error: true);
      }
    }
  }

  void _abrirEdicion(BuildContext context, Verificacion v) {
    if (v.estado == 'Aprobado') {
      mostrarMensaje(context, 'No se puede editar una verificación Aprobada', error: true);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormularioScreen(editar: v)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todas = context.watch<ProyectoProvider>().verificaciones;

    final lista = todas.where((v) {
      final okEstado = _filtroEstado == null || v.estado == _filtroEstado;
      final okNombre = v.modelo.toLowerCase().contains(_busqueda.toLowerCase());
      return okEstado && okNombre;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificaciones ERP'),
        actions: [
          IconButton(
            tooltip: 'Ver reporte',
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ReporteScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          // RI-02: resumen por estado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.spaceAround,
              children: [
                Text('Total: ${todas.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                for (final e in EstadoUI.estados)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(EstadoUI.icono(e), color: EstadoUI.color(e), size: 18),
                    const SizedBox(width: 4),
                    Text('$e: ${todas.where((v) => v.estado == e).length}'),
                  ]),
              ],
            ),
          ),
          // RI-03: búsqueda por modelo
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar por nombre del modelo',
                border: OutlineInputBorder(),
              ),
              onChanged: (t) => setState(() => _busqueda = t),
            ),
          ),
          // RI-03: filtro por estado
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Todos'),
                    selected: _filtroEstado == null,
                    onSelected: (_) => setState(() => _filtroEstado = null),
                  ),
                ),
                for (final e in EstadoUI.estados)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Icon(EstadoUI.icono(e), size: 18, color: EstadoUI.color(e)),
                      label: Text(e),
                      selected: _filtroEstado == e,
                      onSelected: (_) => setState(() => _filtroEstado = e),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: lista.isEmpty
                ? const Center(child: Text('No hay verificaciones que coincidan'))
                : ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (context, i) {
                      final v = lista[i];
                      final color = EstadoUI.color(v.estado);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color,
                          child: Icon(EstadoUI.icono(v.estado), color: Colors.white),
                        ),
                        title: Text('${v.modelo} (v${v.version})'),
                        subtitle: Text(
                            'Verificador: ${v.verificador} - ${v.cumplimiento.toStringAsFixed(1)}%\n${v.estado}',
                            style: TextStyle(color: color)),
                        isThreeLine: true,
                        onTap: () => _abrirEdicion(context, v),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Editar',
                              icon: const Icon(Icons.edit),
                              onPressed: () => _abrirEdicion(context, v),
                            ),
                            IconButton(
                              tooltip: 'Eliminar',
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _confirmarEliminar(context, v.id, '${v.modelo} (v${v.version})'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nueva verificación',
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const FormularioScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}