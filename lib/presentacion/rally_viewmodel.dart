import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../dominio/almacen.dart';
import '../dominio/aparicion.dart';
import '../dominio/excepciones.dart';
import '../dominio/fuentes.dart';
import '../dominio/geo.dart';
import '../dominio/motor_ar.dart';
import '../dominio/partida.dart';
import '../dominio/personaje.dart';
import '../dominio/radar.dart';

/// Controlador principal del Rally de la Independencia.
class RallyViewModel extends ChangeNotifier {
  /// Distancia máxima recomendada al centro de Dolores.
  static const double limiteLejos = 3000;

  final FuentePosicion _posicion;
  final FuenteBrujula _brujula;
  final AlmacenColeccion _almacen;

  final Coordenada centro;
  final double campoVision;
  final double radioMax;

  late final Partida partida;

  RallyViewModel({
    required this._posicion,
    required this._brujula,
    required this._almacen,
    required List<Personaje> personajes,
    required this.centro,
    required math.Random random,
    this.campoVision = 60,
    this.radioMax = 600,
  }) {
    partida = Partida(
      generarApariciones(
        centro: centro,
        personajes: personajes,
        random: random,
        radioMax: 500,
      ),
      reubicar: () => puntoAleatorio(centro, 60, 500, random),
    );
  }

  /// Ubicación actual del jugador.
  Coordenada? usuario;

  /// Dirección hacia la que mira el jugador.
  double? rumbo;

  /// Personajes visibles en la cámara.
  List<Visible> visibles = [];

  /// Mensaje de error para mostrar en la pantalla.
  String? error;

  StreamSubscription<Coordenada>? _subPos;
  StreamSubscription<double>? _subBru;

  /// Indica si todavía falta recibir GPS o brújula.
  bool get esperando => usuario == null || rumbo == null;

  /// Comprueba si el jugador está a más de 3 km
  /// del centro del juego.
  bool get lejosDeDolores =>
      usuario != null && distanciaMetros(usuario!, centro) > limiteLejos;

  /// Obtiene el personaje pendiente más cercano.
  Aparicion? get masCercano {
    final u = usuario;

    if (u == null || partida.pendientes.isEmpty) {
      return null;
    }

    final lista = [...partida.pendientes];

    lista.sort(
      (a, b) => distanciaMetros(
        u,
        a.coordenada,
      ).compareTo(distanciaMetros(u, b.coordenada)),
    );

    return lista.first;
  }

  /// Distancia al personaje pendiente más cercano.
  double? get distanciaAlMasCercano {
    final c = masCercano;

    if (c == null || usuario == null) {
      return null;
    }

    return distanciaMetros(usuario!, c.coordenada);
  }

  /// Temperatura del sistema frío o caliente.
  Temperatura? get temperatura {
    final distancia = distanciaAlMasCercano;

    if (distancia == null) {
      return null;
    }

    return temperaturaPorDistancia(distancia);
  }

  /// Posiciones de los personajes dentro del radar.

  List<(double, double)> get puntosRadar {
    final u = usuario;
    final r = rumbo;

    if (u == null || r == null) {
      return const [];
    }

    final puntos = <(double, double)>[];

    for (final a in partida.pendientes) {
      final punto = puntoEnRadar(
        usuario: u,
        rumbo: r,
        objetivo: a.coordenada,
        alcance: radioMax,
      );

      if (punto != null) {
        puntos.add(punto);
      }
    }

    return puntos;
  }

  /// Inicializa el juego y escucha los sensores.
  Future<void> iniciar() async {
    // Recuperar los personajes capturados anteriormente.
    partida.restaurar(await _almacen.cargarCapturados());

    // Escuchar las actualizaciones del GPS.
    _subPos = _posicion.posiciones.listen((p) {
      usuario = p;
      _recalcular();
    }, onError: _alFallar);

    // Escuchar los cambios de la brújula.
    _subBru = _brujula.rumbos.listen((g) {
      rumbo = rumbo == null ? g : suavizarAngulo(rumbo!, g);

      _recalcular();
    }, onError: _alFallar);

    notifyListeners();
  }

  /// Convierte errores en mensajes seguros.
  void _alFallar(Object e) {
    error = mensajeSeguro(e);
    notifyListeners();
  }

  /// Actualiza la lista de personajes visibles.
  void _recalcular() {
    final u = usuario;
    final r = rumbo;

    if (u != null && r != null) {
      visibles = calcularVisibles(
        usuario: u,
        rumbo: r,
        apariciones: partida.pendientes,
        campoVision: campoVision,
        radioMax: radioMax,
      );
    }

    notifyListeners();
  }

  /// Intenta capturar un personaje.
  ///
  /// Recibe el ID del personaje y la opción elegida.
  Future<ResultadoCaptura> capturar(String id, int opcion) async {
    final u = usuario;

    final aparicion = partida.todas
        .where((a) => a.personaje.id == id)
        .firstOrNull;

    final d = (u == null || aparicion == null)
        ? double.infinity
        : distanciaMetros(u, aparicion.coordenada);

    final resultado = partida.capturar(id, opcion, d);

    // Guardar el progreso si la captura fue correcta.
    if (resultado is Capturado) {
      await _almacen.guardarCapturados(partida.capturados);

      final mejor = await _almacen.cargarMejorPuntaje();

      if (partida.puntos > mejor) {
        await _almacen.guardarMejorPuntaje(partida.puntos);
      }
    }

    // Actualizar la interfaz después de cada intento.
    _recalcular();

    return resultado;
  }

  /// Cancelar los sensores cuando se cierra la pantalla.
  @override
  void dispose() {
    _subPos?.cancel();
    _subBru?.cancel();

    super.dispose();
  }
}
