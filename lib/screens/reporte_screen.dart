import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/proyecto_provider.dart';
import '../utils/estado_ui.dart';

class ReporteScreen extends StatelessWidget {
  const ReporteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProyectoProvider>(context);
    final ultimas = provider.ultimasVersiones;

    if (ultimas.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reporte General')),
        body: const Center(child: Text('Debe registrar al menos una verificación.')),
      );
    }

    String estadoProyecto = 'Aprobado con observaciones';
    if (ultimas.length < 4) {
      estadoProyecto = 'En proceso';
    } else if (ultimas.any((v) => v.estado == 'Rechazado')) {
      estadoProyecto = 'Requiere correcciones';
    } else if (ultimas.every((v) => v.estado == 'Aprobado')) {
      estadoProyecto = 'Aprobado';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reporte General')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado del Proyecto: $estadoProyecto',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Modelos verificados: ${ultimas.length} de 4'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: ultimas.length,
                itemBuilder: (context, index) {
                  final v = ultimas[index];
                  final color = EstadoUI.color(v.estado);
                  final criticos = v.criterios.where((c) => c.esCritico && !c.cumple).toList();

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(EstadoUI.icono(v.estado), color: color),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('${v.modelo} (v${v.version})',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                            Text('${v.cumplimiento.toStringAsFixed(1)}%',
                                style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                          ]),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: v.cumplimiento / 100,
                            minHeight: 10,
                            color: color,
                            backgroundColor: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 8),
                          Text('Estado: ${v.estado}', style: TextStyle(color: color)),
                          if (criticos.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text('Criterios críticos incumplidos:',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                            ...criticos.map((c) => Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.priority_high, color: Colors.red, size: 18),
                                      Expanded(child: Text('${c.codigo}: ${c.descripcion}')),
                                    ],
                                  ),
                                )),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}