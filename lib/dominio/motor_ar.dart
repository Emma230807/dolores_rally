import 'aparicion.dart';
import 'geo.dart';

/// Representa un personaje visible en la cámara.
class Visible {
  final Aparicion aparicion;

  /// Distancia del jugador al personaje.
  final double distancia;

  /// Posición horizontal: 0 izquierda, 1 derecha.
  final double x;

  /// Profundidad: 0 cerca, 1 lejos.
  final double profundidad;

  /// Tamaño del personaje según la distancia.
  final double escala;

  const Visible(
    this.aparicion,
    this.distancia,
    this.x,
    this.profundidad,
    this.escala,
  );
}

/// Determina qué personajes aparecen
/// dentro del campo de visión de la cámara.
List<Visible> calcularVisibles({
  required Coordenada usuario,
  required double rumbo,
  required Iterable<Aparicion> apariciones,
  double campoVision = 60,
  double radioMax = 600,
}) {
  final res = <Visible>[];

  for (final a in apariciones) {
    // Calcular distancia entre jugador y personaje.
    final d = distanciaMetros(usuario, a.coordenada);

    // Descartar personajes demasiado lejanos.
    if (d > radioMax) {
      continue;
    }

    // Calcular la diferencia angular.
    final dif = diferenciaAngular(rumboGrados(usuario, a.coordenada), rumbo);

    // Calcular la posición horizontal.
    final x = posicionHorizontal(dif, campoVision: campoVision);

    // Descartar personajes fuera de la cámara.
    if (x == null) {
      continue;
    }

    // Calcular profundidad entre 0 y 1.
    final prof = (d / radioMax).clamp(0.0, 1.0).toDouble();

    // Calcular tamaño y agregar personaje visible.
    res.add(Visible(a, d, x, prof, 1.2 - 0.6 * prof));
  }

  // Dibujar primero los lejanos y después los cercanos.
  res.sort((a, b) => b.distancia.compareTo(a.distancia));

  return res;
}
