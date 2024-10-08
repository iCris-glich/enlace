import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final dynamic textInput;
  final Color bordercolor;

  const CustomTextfield({
    super.key,
    required this.hintText,
    this.obscureText = false,
    required this.controller,
    this.textInput = TextInputAction.next,
    this.bordercolor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,  // Controla si el texto es visible o no
      decoration: InputDecoration(
        hintText: hintText,  // Texto que aparece cuando no hay input
        hintStyle: const TextStyle(color: Colors.grey),  // Estilo del hint
        filled: true,  // Campo rellenado
        fillColor: Colors.white,  // Color de fondo
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),  // Padding interno
        border: OutlineInputBorder(  // Borde cuando no está seleccionado
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xff010326)),
        ),
        focusedBorder: OutlineInputBorder(  // Borde cuando está enfocado
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xff010326), width: 2),
        ),
        enabledBorder: OutlineInputBorder(  // Borde cuando está habilitado
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: bordercolor, width: 1),
        ),
      ),
    );
  }
}
