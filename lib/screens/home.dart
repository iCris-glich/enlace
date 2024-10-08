import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enlace/provider/provider.dart';
import 'package:enlace/screens/datos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const Inicio(),
    const CrearPublicacion(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_2),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => PerfilUsuario()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              try{
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/sesion');
              } catch (e) {
                Logger().e('Error al cerrar sesion: $e');
              }
            },
          )
        ],
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'Crear Publicación',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class CrearPublicacion extends StatefulWidget {
  const CrearPublicacion({super.key});

  @override
  _CrearPublicacionState createState() => _CrearPublicacionState();
}

class _CrearPublicacionState extends State<CrearPublicacion> {
  TextEditingController textoController = TextEditingController();
  File? _imagen;

  // Función para tomar una foto
  Future<void> tomarFoto1() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagenSeleccionada = await picker.pickImage(
      source: ImageSource.gallery, // O puedes usar ImageSource.camera
      imageQuality: 80, // Calidad de la imagen
    );

    if (imagenSeleccionada != null) {
      setState(() {
        _imagen = File(imagenSeleccionada.path); // Asigna la imagen seleccionada
      });
    }
  }

  // Función para crear la publicación
  Future<void> crearPublicacion() async {
    if (_imagen != null && textoController.text.isNotEmpty) {
      try {
        // Subir imagen a Firebase Storage
        final storageRef = FirebaseStorage.instance.ref();
        final imagenRef = storageRef.child('publicaciones/${DateTime.now().millisecondsSinceEpoch}.jpg');

        await imagenRef.putFile(_imagen!);
        final imagenUrl = await imagenRef.getDownloadURL();
        User? usuario = FirebaseAuth.instance.currentUser;

        String nombreUsuario = 'Usuario Desconocido' ;

        if(usuario != null){
          DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(usuario.uid).get();
          if (userDoc.exists){
            nombreUsuario = userDoc['nombreUsuario'] ?? 'Usuario Desconocido';
          }
        }

        // Guardar en Firestore
        await FirebaseFirestore.instance.collection('publicaciones').add({
          'texto': textoController.text,
          'imagen': imagenUrl,
          'likes': 0,
          'likedBy': [],
          'createdAt': FieldValue.serverTimestamp(),
          'usuarioId' : usuario?.uid,
          'nombreDelUsuario' : nombreUsuario, 
        });

        // Limpiar el formulario
        textoController.clear();
        setState(() {
          _imagen = null; // Reinicia la imagen
        });

        // Muestra un mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publicación creada con éxito')),
        );
      } catch (e) {
        // Manejo de errores
        Logger().e('Error al crear la publicación: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear la publicación')),
        );
      }
    } else {
      // Mensaje de advertencia si falta información
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: textoController,
                decoration: const InputDecoration(
                  hintText: 'Escribe tu publicación aquí...',
                ),
                maxLines: 5,
              ),
              ElevatedButton(
                onPressed: () async {
                  await tomarFoto1();
                },
                child: const Icon(Icons.camera),
              ),
              const SizedBox(height: 20),
              _imagen == null
                  ? const Text('Selecciona una imagen')
                  : Image.file(
                      _imagen!,
                      fit: BoxFit.cover,
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: crearPublicacion,
                child: const Text('Publicar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override  
  EstadoInicio createState() => EstadoInicio();
}

class EstadoInicio extends State<Inicio> {
  final ValueNotifier<Map<String, ValueNotifier<bool>>> likedStatusNotifier = ValueNotifier({});

  @override
  void initState() {
    super.initState();
    likedStatusNotifier.value = {};
    cargarEstadoLikes(); // Llama para cargar los estados de los likes
  }

  Future<void> cargarEstadoLikes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;

      // Obtener todas las publicaciones
      final snapshot = await FirebaseFirestore.instance.collection('publicaciones').get();
      for (var publicacion in snapshot.docs) {
        final likedBy = List<String>.from(publicacion['likedBy'] ?? []);
        likedStatusNotifier.value[publicacion.id] = ValueNotifier(likedBy.contains(uid));
      }
    }
  }

  Future<void> toggleLike(DocumentSnapshot publicacion) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final uid = user.uid;
      final likedBy = List<String>.from(publicacion['likedBy'] ?? []);
      final publicacionId = publicacion.id;

      // Actualizar el estado local sin recargar la lista
      final wasLiked = likedBy.contains(uid);
      if (wasLiked) {
        likedBy.remove(uid); // Quitar like
        likedStatusNotifier.value[publicacionId]?.value = false; // Actualiza el estado local
      } else {
        likedBy.add(uid); // Agregar like
        likedStatusNotifier.value[publicacionId]?.value = true; // Actualiza el estado local
      }

      // Actualiza Firestore
      await FirebaseFirestore.instance.collection('publicaciones').doc(publicacionId).update({
        'likes': wasLiked ? publicacion['likes'] - 1 : publicacion['likes'] + 1,
        'likedBy': likedBy,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('publicaciones').snapshots(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay datos disponibles'));
          }

          final documents = snapshot.data!.docs;
          final publicaciones = documents.map((doc) => Publicacion.fromFirestore(doc)).toList();
          
          return ListView.builder(
            itemCount: publicaciones.length, 
            itemBuilder: (context, index) {
              final publicacion = publicaciones[index];
              final likedStatus = likedStatusNotifier.value[publicacion.documentId] ?? ValueNotifier(false);

              return Padding(
                padding: const EdgeInsets.all(5),
                child: Card(
                  child: Column(
                    children: [
                      Text(publicacion.nombreDelUsuario),
                      Text(publicacion.getTiempoTranscurrido()),
                      publicacion.imagen != null 
                        ? Image.network(publicacion.imagen!) 
                        : Container(),
                      Align(
                        alignment:  Alignment.bottomLeft,
                        child: Text(publicacion.texto),
                      ),
                      Row(
                        children: [
                          ValueListenableBuilder<bool>(
                            valueListenable: likedStatus,
                            builder: (context, isLiked, child) {
                              return IconButton(
                                onPressed: () => toggleLike(documents[index]), // Llama a toggleLike
                                icon: Icon(isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt),
                              );
                            }
                          ),
                          Text('${publicacion.likes}'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}