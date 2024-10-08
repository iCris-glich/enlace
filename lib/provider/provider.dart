import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class Publicacion {
  final String documentId;
  final String nombreDelUsuario;
  final String texto;
  final String? imagen;
  final Timestamp fechaDePublicacion;
  final List<String> likedBy;
  int likes;

  Publicacion({
    required this.documentId,
    required this.nombreDelUsuario,
    required this.texto,
    this.imagen,
    required this.fechaDePublicacion,
    this.likedBy = const [],
    this.likes = 0,
  });

  factory Publicacion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Publicacion(
      documentId: doc.id,
      texto: data['texto'] ?? '',
      imagen: data['imagen'],  // Asignar directamente, puede ser null
      fechaDePublicacion: data['fechaDePublicacion'] ?? Timestamp.now(),
      nombreDelUsuario: data['nombreDelUsuario'] ?? 'Usuario desconocido',
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  // Método para convertir la publicación a un mapa
  Map<String, dynamic> toMap() {
    return {
      'nombreDelUsuario': nombreDelUsuario,
      'texto': texto,
      'imagen': imagen,
      'fechaDePublicacion': fechaDePublicacion,
      'likedBy': likedBy,
      'likes': likes,
    };
  }

 String getTiempoTranscurrido() {
    return timeago.format(fechaDePublicacion.toDate(), locale: 'es');
  }
}



