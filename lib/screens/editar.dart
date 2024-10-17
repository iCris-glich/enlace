import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:logger/logger.dart';

class Editar extends StatefulWidget {
  const Editar({super.key});

  @override
  _EditarState createState() => _EditarState();
}

class _EditarState extends State<Editar> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController usuarioController = TextEditingController();

  File? imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();

  User? usuario;

  @override
  void initState() {
    super.initState();
    obtenerDatosUsuario();
  }

  Future<String> subirImagenAStorage(File imagen) async {
    try {
      String usuarioId = usuario!.uid;
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('imagenes_perfil')
          .child('$usuarioId.jpg');

      UploadTask cargar = storageRef.putFile(imagen);
      TaskSnapshot taskSnapshot = await cargar.whenComplete(() => null);

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      Logger().e('Error al subir la imagen: $e');
      throw 'No se pudo cargar la imagen';
    }
  }

  Future<void> obtenerDatosUsuario() async {
    usuario = FirebaseAuth.instance.currentUser;

    if (usuario != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          nombreController.text = userDoc['nombre'] ?? '';
          apellidoController.text = userDoc['apellido'];
          usuarioController.text = userDoc['nombreUsuario'];
          emailController.text = userDoc['email'] ?? '';
        });
      }
    }
  }

  Future<void> actualizarDatosUsuario() async {
    if (usuario != null) {
      try {
        String? urlImagen;
        if (imagenSeleccionada != null) {
          urlImagen = await subirImagenAStorage(imagenSeleccionada!);
        }

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(usuario!.uid)
            .get();

        if (userDoc.exists) {
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(usuario!.uid)
              .update({
            'nombre': nombreController.text,
            'apellido': apellidoController.text,
            'nombreUsuario': usuarioController.text,
            'email': emailController.text,
            'imagenPerfil': urlImagen ?? '', // Actualizar la URL de la imagen
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Datos actualizados con éxito')),
          );
        } else {
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(usuario!.uid)
              .set({
            'nombre': nombreController.text,
            'apellido': apellidoController.text,
            'nombreUsuario': usuarioController.text,
            'email': emailController.text,
            'imagenPerfil': urlImagen ?? '',
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario creado con éxito')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar los datos')),
        );
      }
    }
  }

  Future<void> seleccionarImagen(ImageSource source) async {
    final XFile? imagen = await _picker.pickImage(source: source);
    if (imagen != null) {
      setState(() {
        imagenSeleccionada = File(imagen.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Datos'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                ),
              ),
              TextField(
                controller: apellidoController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                ),
              ),
              TextField(
                controller: usuarioController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                ),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              imagenSeleccionada != null
                  ? Image.file(imagenSeleccionada!, height: 150)
                  : const Text('No se ha seleccionado ninguna imagen'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => seleccionarImagen(ImageSource.gallery),
                child: const Text('Seleccionar Imagen de la Galería'),
              ),
              ElevatedButton(
                onPressed: () => seleccionarImagen(ImageSource.camera),
                child: const Text('Tomar Foto con la Cámara'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await actualizarDatosUsuario();
                },
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
