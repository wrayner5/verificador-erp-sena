import 'package:flutter/material.dart';

class EstadoUI {
  static const List<String> estados = [
    'Aprobado',
    'Con observaciones',
    'Rechazado',
  ];

  static Color color(String estado) {
    switch (estado) {
      case 'Aprobado':
        return Colors.green;
      case 'Con observaciones':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  static IconData icono(String estado) {
    switch (estado) {
      case 'Aprobado':
        return Icons.check_circle;
      case 'Con observaciones':
        return Icons.warning_amber_rounded;
      default:
        return Icons.cancel;
    }
  }
}

void mostrarMensaje(BuildContext context, String texto, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
String limpiarError(Object e) => e.toString().replaceFirst('Exception: ', '');