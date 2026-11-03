import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/proyecto_provider.dart';

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado del Proyecto: $estadoProyecto', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}