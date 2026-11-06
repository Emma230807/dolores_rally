import 'dart:math' as math;

import 'geo.dart';

/// Calcula la posición de un objetivo en un radar circular.
///
/// Devuelve (x, y) con valores entre -1 y 1.
/// El centro (0, 0) representa al jugador.
/// La parte superior del radar indica hacia dónde mira.
///
/// Devuelve null cuando el objetivo está fuera del alcance.
(double, double)? puntoEnRadar({
  required Coordenada usuario,
  required double rumbo,
  required Coordenada objetivo,
  double alcance = 500,
}) {
  final d = distanciaMetros(usuario, objetivo);

  // No mostrar objetivos fuera del alcance.
  if (d > alcance) {
    return null;
  }

  // Diferencia angular respecto a la dirección del jugador.
  final dif =
      diferenciaAngular(rumboGrados(usuario, objetivo), rumbo) * math.pi / 180;

  // Distancia expresada como fracción del alcance.
  final f = d / alcance;

  // Convertir coordenadas polares a cartesianas.
  return (f * math.sin(dif), -f * math.cos(dif));
}

/// Niveles de proximidad.
/// El orden se utiliza en las pruebas TDD.
enum Temperatura { ardiente, caliente, tibio, frio, helado }

/// Devuelve la temperatura según la distancia.
Temperatura temperaturaPorDistancia(double metros) {
  if (metros <= 15) {
    return Temperatura.ardiente;
  }

  if (metros <= 50) {
    return Temperatura.caliente;
  }

  if (metros <= 150) {
    return Temperatura.tibio;
  }

  if (metros <= 400) {
    return Temperatura.frio;
  }

  return Temperatura.helado;
}

/// Convierte la temperatura en un mensaje para el jugador.
extension TextoTemperatura on Temperatura {
  String get texto => switch (this) {
    Temperatura.helado => '🥶 Helado',
    Temperatura.frio => '❄️ Frío',
    Temperatura.tibio => '🙂 Tibio',
    Temperatura.caliente => '🔥 Caliente',
    Temperatura.ardiente => '🌋 ¡Ardiendo! Atrápalo',
  };
}
