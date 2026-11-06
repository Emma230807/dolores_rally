import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../datos/almacen_prefs.dart';
import '../datos/fuentes_reales.dart';
import '../datos/fuentes_simuladas.dart';
import '../dominio/almacen.dart';
import '../dominio/catalogo.dart';

import 'pantalla_coleccion.dart';
import 'pantalla_rally.dart';
import 'rally_viewmodel.dart';

/// Pantalla principal del Rally de la Independencia AR.
class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  /// Inicia una partida con GPS y brújula reales.
  void _jugarReal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => PantallaRally(
          crearVm: () => RallyViewModel(
            posicion: PosicionGps(),
            brujula: BrujulaReal(),
            almacen: AlmacenPrefs(),
            personajes: personajes,
            centro: plazaPrincipal,
            random: math.Random(),
          ),
        ),
      ),
    );
  }

  /// Inicia una partida con posición y brújula simuladas.
  void _jugarDemo(BuildContext context) {
    final posicion = PosicionSimulada(plazaPrincipal);
    final brujula = BrujulaSimulada();

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => PantallaRally(
          crearVm: () => RallyViewModel(
            posicion: posicion,
            brujula: brujula,
            almacen: AlmacenMemoria(),
            personajes: personajes,
            centro: plazaPrincipal,
            random: math.Random(),
          ),
          controlesDemo: _ControlesDemo(posicion: posicion, brujula: brujula),
        ),
      ),
    ).then((_) {
      // Liberar los simuladores al salir de la partida.
      posicion.cerrar();
      brujula.cerrar();
    });
  }

  /// Abre el álbum de personajes capturados.
  void _abrirAlbum(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            PantallaColeccion(almacen: AlmacenPrefs(), personajes: personajes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rally de la Independencia AR'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Atrapa a los personajes escondidos '
            'en Dolores Hidalgo',
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 8),

          const Text(
            'Usa el radar y el sistema "frío o caliente" '
            'para encontrarlos. Acércate a 15 metros '
            'o menos y responde su pregunta para atraparlos.',
          ),

          const SizedBox(height: 12),

          // Aviso de seguridad.
          Card(
            color: Colors.amber.shade100,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                '⚠️ Mira a tu alrededor, cuida tu paso '
                'y no cruces la calle viendo el teléfono.',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Jugar con GPS real.
          FilledButton.icon(
            onPressed: () => _jugarReal(context),
            icon: const Icon(Icons.explore),
            label: const Text('Jugar en Dolores Hidalgo (GPS real)'),
          ),

          const SizedBox(height: 10),

          // Jugar sin utilizar GPS real.
          OutlinedButton.icon(
            onPressed: () => _jugarDemo(context),
            icon: const Icon(Icons.school),
            label: const Text('Modo demo (salón de clases)'),
          ),

          const SizedBox(height: 10),

          // Consultar álbum.
          OutlinedButton.icon(
            onPressed: () => _abrirAlbum(context),
            icon: const Icon(Icons.collections_bookmark),
            label: const Text('Mi álbum'),
          ),
        ],
      ),
    );
  }
}

/// Controles para caminar y girar virtualmente.
class _ControlesDemo extends StatefulWidget {
  final PosicionSimulada posicion;
  final BrujulaSimulada brujula;

  const _ControlesDemo({required this.posicion, required this.brujula});

  @override
  State<_ControlesDemo> createState() => _ControlesDemoState();
}

class _ControlesDemoState extends State<_ControlesDemo> {
  double _grados = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Control para girar.
          Row(
            children: [
              const Text('Gira', style: TextStyle(color: Colors.white)),

              Expanded(
                child: Slider(
                  min: 0,
                  max: 359,
                  value: _grados,
                  onChanged: (g) {
                    setState(() {
                      _grados = g;
                    });

                    widget.brujula.girar(g);
                  },
                ),
              ),

              Text(
                '${_grados.round()}°',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),

          // Controles para caminar.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: () {
                  widget.posicion.avanzar(_grados, -10);
                },
                child: const Text('⬇ 10 m'),
              ),

              FilledButton(
                onPressed: () {
                  widget.posicion.avanzar(_grados, 10);
                },
                child: const Text('⬆ Avanzar 10 m'),
              ),

              OutlinedButton(
                onPressed: () {
                  widget.posicion.avanzar(_grados, 2);
                },
                child: const Text('+2 m'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
