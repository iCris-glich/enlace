import 'package:enlace/firebase_options.dart';
import 'package:enlace/screens/inicio_de_sesion.dart';
import 'package:enlace/screens/registro.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Manejo de errores al inicializar Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error al inicializar Firebase: $e');
  }

  timeago.setLocaleMessages('es', timeago.EsMessages());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enlace',
      theme: ThemeData(
        primaryColor: const Color(0xffF2E205), // Usa colores constantes
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: AppRoutes.getRoutes(), // Organiza las rutas en una clase separada
      initialRoute: InicioDeSesion.routeName,
    );
  }
}

// Clase separada para las rutas
class AppRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      Registro.routeName: (context) => const Registro(),
      InicioDeSesion.routeName: (context) => const InicioDeSesion(),
      // Agrega más rutas aquí conforme sea necesario
    };
  }
}
