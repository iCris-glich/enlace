import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enlace/screens/home.dart';
import 'package:enlace/widgets/custom_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import necesario para subir la imagen
import 'dart:io';

class Registro extends StatefulWidget {
  static const String routeName = '/registro';

  const Registro({super.key});

  @override
  Estado createState() => Estado();
}

class Estado extends State<Registro> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _apellido = TextEditingController();
  final TextEditingController _nombreUsuario = TextEditingController();
  final TextEditingController _contrasena = TextEditingController();
  final TextEditingController _contraseniaConfirmada = TextEditingController();

  DateTime? fechaNacimiento;
  bool cargando = false;
  final Logger logger = Logger();
  File? imagenPerfil;

  @override
  void dispose() {
    _email.dispose();
    _nombre.dispose();
    _apellido.dispose();
    _nombreUsuario.dispose();
    _contrasena.dispose();
    _contraseniaConfirmada.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: fechaNacimiento ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        fechaNacimiento = fechaSeleccionada;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_esMayorDeEdad(fechaSeleccionada) 
          ? 'Eres mayor de edad' 
          : 'No eres mayor de edad')),
      );
    }
  }

  bool _esMayorDeEdad(DateTime fecha) {
    return DateTime.now().year - fecha.year > 18 ||
      (DateTime.now().year - fecha.year == 18 && 
       DateTime.now().isAfter(DateTime(fecha.year, fecha.month, fecha.day)));
  }

  Future<void> registrarCorreo() async {
    setState(() => cargando = true);

    if (_email.text.isEmpty || 
        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_email.text)) {
      _mostrarSnackBar('Por favor, ingrese un correo electrónico válido');
      setState(() => cargando = false);
      return;
    }

    if (_contrasena.text.length < 6) {
      _mostrarSnackBar('La contraseña debe tener al menos 6 caracteres');
      setState(() => cargando = false);
      return;
    }

    try {
      UserCredential credencial = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text,
        password: _contrasena.text,
      );

      // Subir imagen de perfil a Firebase Storage si se ha seleccionado
      String imagenUrl = '';
      if (imagenPerfil != null) {
        imagenUrl = await _subirImagen(imagenPerfil!); // Lógica para subir la imagen
      }

      await FirebaseFirestore.instance.collection('usuarios').doc(credencial.user!.uid).set({
        'imagenPerfil': imagenUrl,
        'nombre': _nombre.text,
        'apellido': _apellido.text,
        'nombreUsuario': _nombreUsuario.text,
        'email': _email.text,
        'fechaDeNacimiento': fechaNacimiento?.toIso8601String() ?? '',
      });

      await guardarSesionActiva();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animacion, segundaAnimacion) => const Home(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.vertical,
              child: child,
            );
          },
        ),
      );

      _mostrarSnackBar('Se registró exitosamente');
      logger.i('Registro exitoso: $credencial');
    } on FirebaseAuthException catch (e) {
      _manejarErrores(e);
    } catch (e) {
      logger.e('Error inesperado: $e');
      _mostrarSnackBar('Error al registrar el usuario');
    } finally {
      setState(() => cargando = false);
    }
  }

  Future<String> _subirImagen(File imagen) async {
    String nombreImagen = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref().child('imagenes_perfil/$nombreImagen');
    UploadTask uploadTask = ref.putFile(imagen);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> guardarSesionActiva() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _manejarErrores(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        _mostrarSnackBar('El correo ya está en uso');
        break;
      case 'weak-password':
        _mostrarSnackBar('La contraseña es demasiado débil');
        break;
      default:
        _mostrarSnackBar('Error al registrar el usuario: ${e.message}');
    }
  }

  bool _camposValidos() {
    return _email.text.isNotEmpty && 
           _nombre.text.isNotEmpty && 
           _apellido.text.isNotEmpty && 
           _nombreUsuario.text.isNotEmpty && 
           _contrasena.text.isNotEmpty && 
           _contraseniaConfirmada.text.isNotEmpty && 
           fechaNacimiento != null;
  }

  Future<void> _seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();
    final XFile? seleccion = await picker.pickImage(source: ImageSource.gallery);
    if (seleccion != null) {
      setState(() {
        imagenPerfil = File(seleccion.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE0F7FA),
      body: PageView(
        children: [
          _buildPrimeraPantalla(),
          _buildSegundaPantalla(),
          _buildTerceraPantalla(),
        ],
      ),
    );
  }

  Widget _buildPrimeraPantalla() {
    return _buildContainerColumn([
      const Text('Correo electrónico y contraseña', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      CustomTextfield(hintText: 'Email', controller: _email),
      const SizedBox(height: 20),
      CustomTextfield(hintText: 'Contraseña', controller: _contrasena, obscureText: true),
      const SizedBox(height: 20),
      CustomTextfield(hintText: 'Confirmar contraseña', controller: _contraseniaConfirmada, obscureText: true),
    ]);
  }

  Widget _buildSegundaPantalla() {
    return _buildContainerColumn([
      const Text('Nombre y Apellido', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      CustomTextfield(hintText: 'Nombre', controller: _nombre),
      const SizedBox(height: 20),
      CustomTextfield(hintText: 'Apellido', controller: _apellido),
    ]);
  }

  Widget _buildTerceraPantalla() {
    return _buildContainerColumn([
      const Text('Fecha de Nacimiento y Nombre de Usuario', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      CustomTextfield(hintText: 'Nombre de usuario', controller: _nombreUsuario),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () => _seleccionarFecha(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff00796B),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: Text(fechaNacimiento == null 
          ? 'Selecciona tú fecha de nacimiento' 
          : 'Fecha de nacimiento: ${fechaNacimiento!.day}/${fechaNacimiento!.month}/${fechaNacimiento!.year}', style: TextStyle(
            color: Colors.black
          ),),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: _seleccionarImagen,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff00796B),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: Text(imagenPerfil == null 
          ? 'Selecciona tu imagen de perfil' 
          : 'Imagen de perfil seleccionada', style: TextStyle(
            color: Colors.black,
          ),),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff388E3C),
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
        onPressed: _camposValidos() && !cargando ? registrarCorreo : null,
        child: cargando 
          ? const CircularProgressIndicator(color: Colors.white) 
          : const Text('Registrar', style: TextStyle(
            color: Colors.white
          ),),
      ),
    ]);
  }

  Widget _buildContainerColumn(List<Widget> children) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
