import 'package:flutter/material.dart';

import '../dominio/almacen.dart';
import '../dominio/personaje.dart';

/// Álbum de los personajes históricos.
///
/// Los personajes capturados se muestran desbloqueados.
/// Los pendientes aparecen como desconocidos.
class PantallaColeccion extends StatelessWidget {
  final AlmacenColeccion almacen;
  final List<Personaje> personajes;

  const PantallaColeccion({
    super.key,
    required this.almacen,
    required this.personajes,
  });

  /// Recupera los personajes capturados
  /// y el mejor puntaje guardado.
  Future<(Set<String>, int)> _cargar() async {
    return (
      await almacen.cargarCapturados(),
      await almacen.cargarMejorPuntaje(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi álbum'), centerTitle: true),
      body: FutureBuilder<(Set<String>, int)>(
        future: _cargar(),
        builder: (context, snap) {
          // Esperar mientras se recuperan los datos.
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final (ids, mejor) = snap.data!;

          return Column(
            children: [
              // Información del progreso.
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '🏅 ${ids.length}/${personajes.length} · '
                  '⭐ Mejor puntaje: $mejor',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Cuadrícula de personajes.
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(12),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    for (final p in personajes)
                      _Carta(personaje: p, desbloqueado: ids.contains(p.id)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Tarjeta individual de cada personaje.
class _Carta extends StatelessWidget {
  final Personaje personaje;
  final bool desbloqueado;

  const _Carta({required this.personaje, required this.desbloqueado});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: desbloqueado ? null : Colors.grey.shade300,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),

        // Solo se puede abrir un personaje desbloqueado.
        onTap: desbloqueado
            ? () {
                showDialog<void>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('${personaje.emoji} ${personaje.nombre}'),
                      content: Text(personaje.bio),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cerrar'),
                        ),
                      ],
                    );
                  },
                );
              }
            : null,

        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji o signo de interrogación.
              Text(
                desbloqueado ? personaje.emoji : '❓',
                style: const TextStyle(fontSize: 48),
              ),

              const SizedBox(height: 6),

              // Nombre o mensaje de bloqueo.
              Text(
                desbloqueado ? personaje.nombre : 'Por descubrir',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
