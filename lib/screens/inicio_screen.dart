import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/proyecto_provider.dart';
import 'formulario_screen.dart';
import 'reporte_screen.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProyectoProvider>(context);
    final lista = provider.verificaciones;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificaciones ERP'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReporteScreen())),
            tooltip: 'Ver Reporte General',
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16), color: Colors.green.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Total: ${lista.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Aprobados: ${lista.where((v) => v.estado == 'Aprobado').length}'),
              ],
            ),
          ),
          Expanded(
            child: lista.isEmpty
                ? const Center(child: Text('No hay verificaciones registradas'))
                : ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      final v = lista[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: v.estado == 'Aprobado' ? Colors.green : (v.estado == 'Rechazado' ? Colors.red : Colors.orange),
                          child: const Icon(Icons.assignment, color: Colors.white),
                        ),
                        title: Text('${v.modelo} (v${v.version})'),
                        subtitle: Text('Verificador: ${v.verificador} - ${v.cumplimiento}%'),
                        trailing: Text(v.estado),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FormularioScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
