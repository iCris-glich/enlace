import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';


Future<XFile?> cargarImagen() async {
  final ImagePicker tomar = ImagePicker();
  final XFile? imagen = await tomar.pickImage(source: ImageSource.gallery); // O ImageSource.camera
  return imagen;
}

Future<bool> solicitarPermisoCamara() async {
  PermissionStatus estado = await Permission.camera.request();
  return estado.isGranted;
}

Future<bool> solicitarPermisoGaleria() async {
  PermissionStatus estado = await Permission.photos.request();
  return estado.isGranted;
}


Future<XFile?> tomarFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagenSeleccionada = await picker.pickImage(
      source: ImageSource.camera, // O puedes usar ImageSource.gallery
      imageQuality: 80, // Opcional: calidad de la imagen
    );
    return imagenSeleccionada;
  }

