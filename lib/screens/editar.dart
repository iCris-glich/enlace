import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Editar extends StatefulWidget {
  const Editar({Key? key}) : super(key: key);

  @override
  _EditarState createState() => _EditarState();
}

class _EditarState extends State<Editar> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  File? imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();

  User? usuario;

  @override
  void initState() {
    super.initState();
    obtenerDatosUsuario();
  }

  Future<void> obtenerDatosUsuario() async {
    usuario = FirebaseAuth.instance.currentUser;

    if (usuario != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(usuario!.uid).get();
      
      if (userDoc.exists) {
        setState(() {
          nombreController.text = userDoc['nombreUsuario'] ?? '';
          emailController.text = userDoc['email'] ?? '';
        });
      }
    }
  }

  Future<void> actualizarDatosUsuario() async {
    if (usuario != null) {
      try {
        // Asumiendo que tienes un método para subir la imagen a Firebase Storage y obtener la URL
        String? urlImagen;
        if (imagenSeleccionada != null) {
          // Subir la imagen a Firebase Storage y obtener la URL
          urlImagen = await subirImagenAStorage(imagenSeleccionada!);
        }

        await FirebaseFirestore.instance.collection('usuarios').doc(usuario!.uid).update({
          'nombre': nombreController.text,
          'email': emailController.text,
          'imagenPerfil': urlImagen ?? '', // Actualizar la URL de la imagen
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos actualizados con éxito')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar los datos')),
        );
      }
    }
  }

  // Función para subir imagen a Firebase Storage
  Future<String> subirImagenAStorage(File imagen) async {
    // Aquí subirías la imagen a Firebase Storage y obtendrías la URL
    // Debes implementar esta función para manejar la subida y obtener el enlace
    return 'URL_DE_LA_IMAGEN_SUBIDA';
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
      body: Padding(
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
              onPressed: actualizarDatosUsuario,
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
