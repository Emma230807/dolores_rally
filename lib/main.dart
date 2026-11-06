import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'presentacion/pantalla_inicio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mantener la aplicación en orientación vertical.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MiAplicacion());
}

class MiAplicacion extends StatelessWidget {
  const MiAplicacion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rally de la Independencia AR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const PantallaInicio(),
    );
  }
}
