import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enlace/screens/editar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class PerfilUsuario extends StatefulWidget {
  const PerfilUsuario({Key? key}) : super(key: key);

  @override
  _PerfilUsuarioState createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  User? usuario;
  String nombre = '';
  String apellido = '';
  String nombreUsuario = '';
  String email = '';
  String imagenUrl =
      'https://images.vexels.com/media/users/3/137047/isolated/preview/5831a17a290077c646a48c4db78a81bb-icono-de-perfil-de-usuario-azul.png'; // URL por defecto

  @override
  void initState() {
    super.initState();
    Logger().i('a sido ejecutado');
    obtenerDatosUsuario();
  }

  Future<void> obtenerDatosUsuario() async {
    usuario = FirebaseAuth.instance.currentUser;

    if (usuario != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('usuarios').doc(usuario!.uid).get();

      if (userDoc.exists) {
        setState(() {
          nombre = userDoc['nombre'] ?? '';
          apellido = userDoc['apellido'] ?? '';
          nombreUsuario = userDoc['nombreUsuario'] ?? '';
          email = userDoc['email'] ?? '';
          imagenUrl = userDoc['imagenPerfil'] ?? imagenUrl; // Obtener la URL de la imagen
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datos del Usuario',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.network(
                        imagenUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // En caso de error, muestra una imagen por defecto
                          return Image.network(
                            'https://images.vexels.com/media/users/3/137047/isolated/preview/5831a17a290077c646a48c4db78a81bb-icono-de-perfil-de-usuario-azul.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    Text(
                      'Nombre: $nombre',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Apellido: $apellido',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Nombre de Usuario: $nombreUsuario',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Email: $email',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Editar()), // Navegar a la pantalla de edición
                  );
                },
                child: const Text('Editar Datos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
