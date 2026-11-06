import 'aparicion.dart';
import 'excepciones.dart';
import 'geo.dart';

/// Resultado de intentar capturar un personaje.
sealed class ResultadoCaptura {
  const ResultadoCaptura();
}

/// El jugador respondió correctamente.
class Capturado extends ResultadoCaptura {
  final int puntos;

  const Capturado(this.puntos);
}

/// El jugador respondió incorrectamente,
/// pero todavía tiene oportunidades.
class Fallo extends ResultadoCaptura {
  final int intentosRestantes;

  const Fallo(this.intentosRestantes);
}

/// El personaje escapó y cambió de ubicación.
class SeEscapo extends ResultadoCaptura {
  final Coordenada nuevaPosicion;

  const SeEscapo(this.nuevaPosicion);
}

/// Administra las reglas de captura del juego.
class Partida {
  static const double radioCaptura = 15;
  static const int maxFallos = 2;
  static const int puntosPrimerIntento = 100;
  static const int puntosSegundoIntento = 50;

  final Map<String, Aparicion> _apariciones;
  final Coordenada Function() _reubicar;

  final Set<String> _capturados = {};
  final Map<String, int> _fallos = {};

  int puntos = 0;

  Partida(List<Aparicion> apariciones, {required this._reubicar})
    : _apariciones = {for (final a in apariciones) a.personaje.id: a};

  /// Todos los personajes registrados.
  List<Aparicion> get todas => _apariciones.values.toList();

  /// Personajes que todavía no han sido capturados.
  List<Aparicion> get pendientes => _apariciones.values
      .where((a) => !_capturados.contains(a.personaje.id))
      .toList();

  /// Identificadores de los personajes capturados.
  Set<String> get capturados => Set.unmodifiable(_capturados);

  /// La partida termina al capturar todos los personajes.
  bool get terminada => _capturados.length == _apariciones.length;

  /// Comprueba si un personaje ya fue capturado.
  bool estaCapturado(String id) => _capturados.contains(id);

  /// Recupera capturas guardadas anteriormente.
  /// Ignora los identificadores desconocidos.
  void restaurar(Iterable<String> ids) {
    _capturados.addAll(ids.where(_apariciones.containsKey));
  }

  /// Intenta capturar un personaje.
  ///
  /// id: identificador del personaje.
  /// opcion: índice de la respuesta seleccionada.
  /// distanciaMetros: distancia actual al personaje.
  ResultadoCaptura capturar(String id, int opcion, double distanciaMetros) {
    final a = _apariciones[id];

    // Verificar que el personaje exista.
    if (a == null) {
      throw const PersonajeDesconocidoException();
    }

    // Evitar capturas duplicadas.
    if (_capturados.contains(id)) {
      throw const YaCapturadoException();
    }

    // Verificar que esté dentro del radio de captura.
    if (distanciaMetros > radioCaptura) {
      throw LejosException(distanciaMetros);
    }

    final fallosPrevios = _fallos[id] ?? 0;

    // RESPUESTA CORRECTA.
    if (a.personaje.pregunta.esCorrecta(opcion)) {
      final ganados = fallosPrevios == 0
          ? puntosPrimerIntento
          : puntosSegundoIntento;

      puntos += ganados;

      _capturados.add(id);

      return Capturado(ganados);
    }

    // RESPUESTA INCORRECTA.
    final fallos = fallosPrevios + 1;

    // Si falla dos veces, el personaje escapa.
    if (fallos >= maxFallos) {
      _fallos[id] = 0;

      final nueva = _reubicar();

      _apariciones[id] = Aparicion(a.personaje, nueva);

      return SeEscapo(nueva);
    }

    // Todavía tiene un intento disponible.
    _fallos[id] = fallos;

    return Fallo(maxFallos - fallos);
  }
}
