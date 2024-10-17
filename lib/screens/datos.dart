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
    try {
      usuario = FirebaseAuth.instance.currentUser;

      if (usuario != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(usuario!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            nombre = userDoc['nombre'] ?? '';
            apellido = userDoc['apellido'] ?? '';
            nombreUsuario = userDoc['nombreUsuario'] ?? '';
            email = userDoc['email'] ?? '';
            imagenUrl = userDoc['imagenPerfil'] ??
                imagenUrl; // Obtener la URL de la imagen
          });
        }
      }
    } catch (e) {
      Logger().e('Error al obtener los datos del usuario: $e');
      // Puedes mostrar un mensaje de error o notificar al usuario
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Banner Image con manejo de errores
                  Image.network(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQjy1E10RfX3Tvb4E1aFOXOE1vQ1YaE-andnw&s',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error,
                          size: 100, color: Colors.red);
                    },
                  ),
                  // Profile Picture con manejo de errores
                  Positioned(
                    bottom: -50,
                    child: CircleAvatar(
                      radius: 60,
                      child: ClipOval(
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/images/perfil.jpg',
                          image: imagenUrl,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error,
                                size: 100, color: Colors.red);
                          },
                        ),
                      ),
                    ),
                  ),
                  // Edit Icon
                  Positioned(
                    right: 110,
                    child: InkWell(
                      onTap: () async {
                        try {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Editar()),
                          );
                        } catch (e) {
                          Logger().e(
                              'Error al navegar a la pantalla de edición: $e');
                          // Manejo de errores en la navegación
                        }
                      },
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80), // Space for profile picture
              // User Info
              Text(
                nombre,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                apellido,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Text(
                nombreUsuario,
                style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
