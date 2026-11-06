abstract class ErrorDeApp implements Exception {
  const ErrorDeApp();
}

/// El jugador no otorgó permisos de ubicación.
class PermisoUbicacionException extends ErrorDeApp {
  const PermisoUbicacionException();

  @override
  String toString() =>
      'Necesito el permiso de ubicación para jugar. '
      'Actívalo en Ajustes.';
}

/// El GPS del dispositivo está apagado.
class UbicacionApagadaException extends ErrorDeApp {
  const UbicacionApagadaException();

  @override
  String toString() => 'El GPS está apagado. Actívalo para jugar.';
}

/// El dispositivo no tiene brújula.
class SinBrujulaException extends ErrorDeApp {
  const SinBrujulaException();

  @override
  String toString() => 'Este dispositivo no tiene brújula. Usa el modo demo.';
}

/// El jugador está demasiado lejos para capturar.
class LejosException extends ErrorDeApp {
  final double metros;

  const LejosException(this.metros);

  @override
  String toString() =>
      'Estás a ${metros.round()} m. '
      'Acércate a menos de 15 m para atraparlo.';
}

/// El personaje ya fue capturado.
class YaCapturadoException extends ErrorDeApp {
  const YaCapturadoException();

  @override
  String toString() => 'Ya atrapaste a este personaje.';
}

/// El identificador no corresponde a ningún personaje.
class PersonajeDesconocidoException extends ErrorDeApp {
  const PersonajeDesconocidoException();

  @override
  String toString() => 'Ese personaje no existe en el juego.';
}

/// Devuelve un mensaje seguro para mostrar al jugador.
String mensajeSeguro(Object error) => error is ErrorDeApp
    ? error.toString()
    : 'Ocurrió un error inesperado. Intenta de nuevo.';
