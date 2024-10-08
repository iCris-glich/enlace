import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

Future <void> sesion (String email, String contrasenia) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email, 
    password: contrasenia
    );
    logger.i('Sesion iniciada con exito');
  } catch (e) {
    logger.e('Error $e al iniciar sesion');
  }
}

Future<UserCredential?> google() async {
  try {
    final GoogleSignInAccount? googleUsuario = await GoogleSignIn().signIn();

    if (googleUsuario == null) {
      // Usuario canceló el proceso de inicio de sesión
      logger.e('El proceso de inicio de sesión fue cancelado.');
      return null;
    }

    final GoogleSignInAuthentication googleAutenticado = await googleUsuario.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAutenticado.accessToken,
      idToken: googleAutenticado.idToken,
    );

    // Iniciar sesión en Firebase con las credenciales de Google
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    // Obtener el usuario y su UID
    final User? usuario = userCredential.user;
    if (usuario != null) {
      String uid = usuario.uid;
      logger.i('Inicio de sesión exitoso. UID del usuario: $uid');
    }

    return userCredential;
  } catch (error) {
    logger.e('Error durante el inicio de sesión con Google: $error');
    return null;
  }
}
