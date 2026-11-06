import 'dart:math' as math;

/// Matemáticas de la realidad aumentada por ubicación.
/// Dart puro: sin Flutter, sin GPS y sin cámara.

class Coordenada {
  final double lat;
  final double lon;

  const Coordenada(this.lat, this.lon);

  @override
  String toString() => '(${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)})';
}

/// Radio aproximado de la Tierra en metros.
const double _radioTierra = 6371000.0;

/// Convertir grados a radianes.
double _rad(double grados) => grados * math.pi / 180;

/// Convertir radianes a grados.
double _grados(double rad) => rad * 180 / math.pi;

/// Calcula la distancia en metros entre dos coordenadas.
/// Utiliza la fórmula de Haversine.
double distanciaMetros(Coordenada a, Coordenada b) {
  final dLat = _rad(b.lat - a.lat);
  final dLon = _rad(b.lon - a.lon);

  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(_rad(a.lat)) *
          math.cos(_rad(b.lat)) *
          math.pow(math.sin(dLon / 2), 2);

  return 2 * _radioTierra * math.asin(math.sqrt(h.clamp(0.0, 1.0).toDouble()));
}

/// Calcula el rumbo desde una coordenada hacia otra.
/// 0° = norte, 90° = este, 180° = sur, 270° = oeste.
double rumboGrados(Coordenada a, Coordenada b) {
  final dLon = _rad(b.lon - a.lon);
  final lat1 = _rad(a.lat);
  final lat2 = _rad(b.lat);

  final y = math.sin(dLon) * math.cos(lat2);

  final x =
      math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

  return normalizar360(_grados(math.atan2(y, x)));
}

/// Normaliza un ángulo entre 0° y 360°.
/// Corrige pequeñas imprecisiones de punto flotante
/// cuando el resultado está prácticamente en 360°.
double normalizar360(double grados) {
  final resultado = ((grados % 360) + 360) % 360;

  if ((360 - resultado).abs() < 1e-9) {
    return 0;
  }

  return resultado;
}

/// Calcula la diferencia angular más corta.
/// El resultado se encuentra entre -180° y 180°.
double diferenciaAngular(double objetivo, double actual) {
  var d = normalizar360(objetivo - actual);

  if (d > 180) {
    d -= 360;
  }

  return d;
}

/// Suaviza los movimientos de la brújula.
/// Evita saltos bruscos al cruzar de 359° a 0°.
double suavizarAngulo(double anterior, double nuevo, {double alfa = 0.2}) {
  return normalizar360(anterior + alfa * diferenciaAngular(nuevo, anterior));
}

/// Calcula la posición horizontal de un objeto.
/// 0 = izquierda, 0.5 = centro, 1 = derecha.
/// Devuelve null si está fuera del campo de visión.
double? posicionHorizontal(double diferencia, {double campoVision = 60}) {
  if (diferencia.abs() > campoVision / 2) {
    return null;
  }

  return 0.5 + diferencia / campoVision;
}

/// Formatea la distancia para mostrarla en pantalla.
String formatearDistancia(double metros) {
  return metros < 1000
      ? '${metros.round()} m'
      : '${(metros / 1000).toStringAsFixed(1)} km';
}

/// Convierte un ángulo en una dirección cardinal.
String nombreCardinal(double grados) {
  const puntos = ['N', 'NE', 'E', 'SE', 'S', 'SO', 'O', 'NO'];

  return puntos[((normalizar360(grados) + 22.5) ~/ 45) % 8];
}

/// Calcula las coordenadas de destino cuando se camina
/// cierta distancia desde un punto inicial y con un rumbo.
///
/// origen: coordenada inicial.
/// rumbo: dirección en grados.
/// metros: distancia que se recorrerá.
Coordenada destino(Coordenada origen, double rumbo, double metros) {
  final d = metros / _radioTierra;
  final br = _rad(rumbo);

  final lat1 = _rad(origen.lat);
  final lon1 = _rad(origen.lon);

  final lat2 = math.asin(
    math.sin(lat1) * math.cos(d) + math.cos(lat1) * math.sin(d) * math.cos(br),
  );

  final lon2 =
      lon1 +
      math.atan2(
        math.sin(br) * math.sin(d) * math.cos(lat1),
        math.cos(d) - math.sin(lat1) * math.sin(lat2),
      );

  return Coordenada(_grados(lat2), ((_grados(lon2) + 540) % 360) - 180);
}
