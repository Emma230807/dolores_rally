/// Contrato para guardar el progreso del jugador.
/// Solo guardamos identificadores y puntajes.
/// Nunca almacenamos coordenadas del jugador.
abstract class AlmacenColeccion {
  Future<Set<String>> cargarCapturados();

  Future<void> guardarCapturados(Set<String> ids);

  Future<int> cargarMejorPuntaje();

  Future<void> guardarMejorPuntaje(int puntos);
}

/// Almacenamiento temporal para pruebas y modo DEMO.
class AlmacenMemoria implements AlmacenColeccion {
  Set<String> _ids = {};
  int _mejor = 0;

  @override
  Future<Set<String>> cargarCapturados() async {
    return {..._ids};
  }

  @override
  Future<void> guardarCapturados(Set<String> ids) async {
    _ids = {...ids};
  }

  @override
  Future<int> cargarMejorPuntaje() async {
    return _mejor;
  }

  @override
  Future<void> guardarMejorPuntaje(int puntos) async {
    _mejor = puntos;
  }
}
