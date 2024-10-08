import 'package:shared_preferences/shared_preferences.dart';

class Preferencias {
  static final Preferencias _instancia = Preferencias._internal();

  factory Preferencias() {
    return _instancia;
  }

  Preferencias._internal();

  static late SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  String get ultimaPagina {
    return _preferences.getString('ultimaPagina') ?? '/registro';
  }

  set ultimaPagina(String value) {
    _preferences.setString('ultimaPagina', value);
  }
}
