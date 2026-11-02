
class Criterio {
  final String codigo;
  final String descripcion;
  final bool esCritico;
  bool cumple;
  String observacion;

  Criterio({
    required this.codigo,
    required this.descripcion,
    required this.esCritico,
    this.cumple = false,
    this.observacion = '',
  });

  bool validarObservacion() {
    if (!cumple && observacion.trim().length < 15) {
      return false;
    }

    return true;
  }
}

