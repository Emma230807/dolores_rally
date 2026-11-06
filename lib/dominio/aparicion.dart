import 'dart:math' as math;

import 'geo.dart';
import 'personaje.dart';

/// Representa un personaje escondido
/// en un punto del mapa.
class Aparicion {
  final Personaje personaje;
  final Coordenada coordenada;

  const Aparicion(this.personaje, this.coordenada);
}

/// Genera una coordenada aleatoria entre
/// una distancia mínima y máxima del centro.
///
/// La raíz cuadrada permite distribuir
/// los puntos uniformemente por área.
Coordenada puntoAleatorio(
  Coordenada centro,
  double min,
  double max,
  math.Random random,
) {
  final distancia = math.sqrt(
    min * min + random.nextDouble() * (max * max - min * min),
  );

  final rumbo = random.nextDouble() * 360;

  return destino(centro, rumbo, distancia);
}

/// Genera una aparición por cada personaje.
///
/// La instancia Random se recibe como parámetro
/// para permitir pruebas reproducibles.
List<Aparicion> generarApariciones({
  required Coordenada centro,
  required List<Personaje> personajes,
  required math.Random random,
  double radioMin = 60,
  double radioMax = 500,
}) {
  return [
    for (final personaje in personajes)
      Aparicion(personaje, puntoAleatorio(centro, radioMin, radioMax, random)),
  ];
}
