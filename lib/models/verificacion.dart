
import 'criterio.dart';

class Verificacion {
  final String id;
  final String modelo;
  final int version;
  final String verificador;
  final DateTime fecha;
  final List<Criterio> criterios;

  Verificacion({
    required this.id,
    required this.modelo,
    required this.version,
    required this.verificador,
    required this.fecha,
    required this.criterios,
  });

  double get cumplimiento {
    int puntosTotales = 0;
    int puntosObtenidos = 0;

    for (var crit in criterios) {
      int valor = crit.esCritico ? 2 : 1;

      puntosTotales += valor;

      if (crit.cumple) {
        puntosObtenidos += valor;
      }
    }

    if (puntosTotales == 0) return 0.0;

    return (puntosObtenidos / puntosTotales) * 100;
  }

  String get estado {
    double porc = cumplimiento;

    int criticosIncumplidos = criterios
        .where((c) => c.esCritico && !c.cumple)
        .length;

    if (criticosIncumplidos >= 2) {
      return 'Rechazado';
    }

    if (porc >= 80 && criticosIncumplidos == 0) {
      return 'Aprobado';
    }

    if (porc >= 60) {
      return 'Con observaciones';
    }

    return 'Rechazado';
  }
}
