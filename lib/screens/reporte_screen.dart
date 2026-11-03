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

    return Scaffold(
      appBar: AppBar(title: const Text('Reporte General')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Calculando reporte...'),
      ),
    );
  }
}