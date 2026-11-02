
import 'package:flutter_test/flutter_test.dart';
import 'package:verificador_erp_sena/models/criterio.dart';
import 'package:verificador_erp_sena/models/verificacion.dart';
import 'package:verificador_erp_sena/providers/proyecto_provider.dart';

// Crear criterios para las pruebas.
Criterio crearCriterio({
  required bool critico,
  required bool cumple,
}) {
  return Criterio(
    codigo: 'TEST-01',
    descripcion: 'Criterio de prueba',
    esCritico: critico,
    cumple: cumple,
  );
}

// Crear verificaciones para las pruebas.
Verificacion crearVerificacion({
  required String modelo,
  required int version,
  String verificador = 'Wrayner',
  List<Criterio> criterios = const [],
}) {
  return Verificacion(
    id: '$modelo-$version',
    modelo: modelo,
    version: version,
    verificador: verificador,
    fecha: DateTime(2026, 11, 2),
    criterios: criterios,
  );
}

void main() {
  // ==========================================
  // PRUEBAS DE LA CLASE CRITERIO
  // ==========================================

  group('Pruebas de Criterio', () {
    test('Observación de 15 caracteres es válida', () {
      final c = crearCriterio(
        critico: false,
        cumple: false,
      );

      c.observacion = '123456789012345';

      expect(c.validarObservacion(), true);
    });

    test('Observación de 14 caracteres no es válida', () {
      final c = crearCriterio(
        critico: false,
        cumple: false,
      );

      c.observacion = '12345678901234';

      expect(c.validarObservacion(), false);
    });

    test('Criterio cumplido no necesita observación', () {
      final c = crearCriterio(
        critico: true,
        cumple: true,
      );

      expect(c.validarObservacion(), true);
    });
  });

  // ==========================================
  // PRUEBAS DE LA CLASE VERIFICACION
  // ==========================================

  group('Pruebas de Verificacion', () {
    test('Sin criterios el cumplimiento es cero', () {
      final v = crearVerificacion(
        modelo: 'Clases',
        version: 1,
      );

      expect(v.cumplimiento, 0.0);
    });

    test('Los criterios críticos valen dos puntos', () {
      final v = crearVerificacion(
        modelo: 'Clases',
        version: 1,
        criterios: [
          crearCriterio(critico: true, cumple: true),
          crearCriterio(critico: false, cumple: false),
        ],
      );

      expect(v.cumplimiento, closeTo(66.67, 0.01));
    });

    test('Una verificación con 100% queda aprobada', () {
      final v = crearVerificacion(
        modelo: 'Casos de uso',
        version: 1,
        criterios: [
          crearCriterio(critico: true, cumple: true),
          crearCriterio(critico: false, cumple: true),
          crearCriterio(critico: false, cumple: true),
        ],
      );

      expect(v.estado, 'Aprobado');
    });

    test('Un crítico incumplido impide la aprobación', () {
      final v = crearVerificacion(
        modelo: 'Secuencia',
        version: 1,
        criterios: [
          crearCriterio(critico: true, cumple: false),
          ...List.generate(
            8,
            (_) => crearCriterio(
              critico: false,
              cumple: true,
            ),
          ),
        ],
      );

      expect(v.estado, 'Con observaciones');
    });

    test('Dos críticos incumplidos generan rechazo', () {
      final v = crearVerificacion(
        modelo: 'Actividades',
        version: 1,
        criterios: [
          crearCriterio(critico: true, cumple: false),
          crearCriterio(critico: true, cumple: false),
          ...List.generate(
            10,
            (_) => crearCriterio(
              critico: false,
              cumple: true,
            ),
          ),
        ],
      );

      expect(v.estado, 'Rechazado');
    });

    test('Menos del 60% genera rechazo', () {
      final v = crearVerificacion(
        modelo: 'Clases',
        version: 1,
        criterios: [
          crearCriterio(critico: true, cumple: true),
          ...List.generate(
            4,
            (_) => crearCriterio(
              critico: false,
              cumple: false,
            ),
          ),
        ],
      );

      expect(v.estado, 'Rechazado');
    });
  });

  // ==========================================
  // PRUEBAS DEL PROYECTO PROVIDER
  // ==========================================

  group('Pruebas de ProyectoProvider', () {
    test('No permite un verificador con menos de 3 letras', () {
      final provider = ProyectoProvider();
      addTearDown(provider.dispose);

      final v = crearVerificacion(
        modelo: 'Clases',
        version: 1,
        verificador: 'AB',
      );

      expect(
        () => provider.agregarVerificacion(v),
        throwsA(isA<Exception>()),
      );
    });

    test('No permite registrar una versión repetida', () {
      final provider = ProyectoProvider();
      addTearDown(provider.dispose);

      provider.agregarVerificacion(
        crearVerificacion(
          modelo: 'Clases',
          version: 1,
        ),
      );

      expect(
        () => provider.agregarVerificacion(
          crearVerificacion(
            modelo: 'Clases',
            version: 1,
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Permite registrar una versión superior', () {
      final provider = ProyectoProvider();
      addTearDown(provider.dispose);

      provider.agregarVerificacion(
        crearVerificacion(
          modelo: 'Clases',
          version: 1,
        ),
      );

      provider.agregarVerificacion(
        crearVerificacion(
          modelo: 'Clases',
          version: 2,
        ),
      );

      expect(provider.verificaciones.length, 2);
    });

    // RN-11: No permite editar verificaciones aprobadas.
    test('No permite editar una verificación aprobada', () {
      final provider = ProyectoProvider();
      addTearDown(provider.dispose);

      provider.agregarVerificacion(
        crearVerificacion(
          modelo: 'Clases',
          version: 1,
          criterios: [
            crearCriterio(
              critico: true,
              cumple: true,
            ),
          ],
        ),
      );

      expect(
        () => provider.editarVerificacion(
          crearVerificacion(
            modelo: 'Clases',
            version: 1,
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });

    // RN-12: No permite eliminar verificaciones aprobadas.
    test('No permite eliminar una verificación aprobada', () {
      final provider = ProyectoProvider();
      addTearDown(provider.dispose);

      provider.agregarVerificacion(
        crearVerificacion(
          modelo: 'Clases',
          version: 1,
          criterios: [
            crearCriterio(
              critico: true,
              cumple: true,
            ),
          ],
        ),
      );

      expect(
        () => provider.eliminarVerificacion('Clases-1'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
