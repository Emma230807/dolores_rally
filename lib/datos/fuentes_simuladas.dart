import 'dart:async';

import '../dominio/fuentes.dart';
import '../dominio/geo.dart';

/// Permite simular que el jugador camina.
///
/// Ideal para probar el juego sin salir del salón.
class PosicionSimulada implements FuentePosicion {
  Coordenada _actual;

  final _controlador = StreamController<Coordenada>.broadcast();

  PosicionSimulada(this._actual);

  @override
  Stream<Coordenada> get posiciones async* {
    // Entregar la posición inicial.
    yield _actual;

    // Escuchar los movimientos posteriores.
    yield* _controlador.stream;
  }

  /// Avanza o retrocede una cantidad de metros.
  ///
  /// Si metros es negativo, camina hacia atrás.
  void avanzar(double rumbo, double metros) {
    _actual = metros >= 0
        ? destino(_actual, rumbo, metros)
        : destino(_actual, rumbo + 180, -metros);

    _controlador.add(_actual);
  }

  /// Libera los recursos del simulador.
  void cerrar() {
    _controlador.close();
  }
}

/// Permite simular la orientación de la brújula.
class BrujulaSimulada implements FuenteBrujula {
  final _controlador = StreamController<double>.broadcast();

  double _ultimo = 0;

  @override
  Stream<double> get rumbos async* {
    // Entregar el rumbo inicial.
    yield _ultimo;

    // Escuchar los giros posteriores.
    yield* _controlador.stream;
  }

  /// Cambia la dirección de la brújula virtual.
  void girar(double grados) {
    _ultimo = grados;

    _controlador.add(grados);
  }

  /// Libera los recursos del simulador.
  void cerrar() {
    _controlador.close();
  }
}
