import 'geo.dart';

/// Contrato para obtener la posición del jugador.
///
/// No importa si viene del GPS real o de un simulador.
abstract class FuentePosicion {
  Stream<Coordenada> get posiciones;
}

/// Contrato para obtener la dirección del jugador.
///
/// 0 grados = norte.
/// 90 grados = este.
/// 180 grados = sur.
/// 270 grados = oeste.
abstract class FuenteBrujula {
  Stream<double> get rumbos;
}
