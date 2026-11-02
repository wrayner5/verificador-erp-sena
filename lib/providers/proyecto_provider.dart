
import 'package:flutter/material.dart';
import '../models/verificacion.dart';

class ProyectoProvider extends ChangeNotifier {
  final List<Verificacion> _verificaciones = [];

  List<Verificacion> get verificaciones => _verificaciones;

  List<Verificacion> get ultimasVersiones {
    Map<String, Verificacion> mapa = {};

    for (var v in _verificaciones) {
      if (!mapa.containsKey(v.modelo) ||
          v.version > mapa[v.modelo]!.version) {
        mapa[v.modelo] = v;
      }
    }

    return mapa.values.toList();
  }

  void agregarVerificacion(Verificacion nueva) {
    if (nueva.verificador.trim().length < 3) {
      throw Exception("Verificador mínimo 3 letras.");
    }

    var previas = _verificaciones
        .where((v) => v.modelo == nueva.modelo)
        .toList();

    if (previas.isNotEmpty) {
      int maxV = previas
          .map((v) => v.version)
          .reduce((a, b) => a > b ? a : b);

      if (nueva.version <= maxV) {
        throw Exception(
          "Versión debe ser mayor a la registrada.",
        );
      }
    }

    _verificaciones.add(nueva);
    notifyListeners();
  }

  // RN-11: No permitir editar verificaciones aprobadas.
  void editarVerificacion(Verificacion actualizada) {
    int indice = _verificaciones.indexWhere(
      (v) => v.id == actualizada.id,
    );

    if (indice == -1) {
      throw Exception("Verificación no encontrada.");
    }

    if (_verificaciones[indice].estado == 'Aprobado') {
      throw Exception(
        "No se puede editar una verificación Aprobada.",
      );
    }

    _verificaciones[indice] = actualizada;
    notifyListeners();
  }

  // RN-12: No permitir eliminar verificaciones aprobadas.
  void eliminarVerificacion(String id) {
    int indice = _verificaciones.indexWhere(
      (v) => v.id == id,
    );

    if (indice == -1) {
      throw Exception("Verificación no encontrada.");
    }

    if (_verificaciones[indice].estado == 'Aprobado') {
      throw Exception(
        "No se puede eliminar verificación Aprobada",
      );
    }

    _verificaciones.removeAt(indice);
    notifyListeners();
  }
}
