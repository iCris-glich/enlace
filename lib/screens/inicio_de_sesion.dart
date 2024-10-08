import 'package:enlace/screens/home.dart';
import 'package:enlace/screens/registro.dart';
import 'package:enlace/services/firebase.dart';
import 'package:enlace/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class InicioDeSesion extends StatefulWidget{
  static const String routeName = '/sesion';

  const InicioDeSesion({super.key});
  
  @override  
  Estado createState() => Estado();
}

class Estado extends State <InicioDeSesion> {

  TextEditingController email = TextEditingController();
  TextEditingController contrasenia = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [
            const SizedBox(
              height: 50,
            ),
            const Text('Inicia sesion para seguir', style: TextStyle(
              fontSize: 30, 
              fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            CustomTextfield(
              hintText: 'Email', 
              controller: email,
            ),
            const SizedBox(
              height: 20,
            ),
             CustomTextfield(
              hintText: 'Contraseña', 
              controller: contrasenia
            ),
            const SizedBox(
              height: 30,
            ),
            TextButton(
              onPressed: () async {
                await Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => const Registro()));
              }, 
              child: const Text('¿ No tiene una cuenta con nosotros ?')
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () async {
                if (contrasenia.text.isNotEmpty && email.text.isNotEmpty){
                  await sesion(
                  email.text.trim(), 
                  contrasenia.text.trim(),
                );
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => Home())
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rellena todas las casillas'))
                 );
                }
              }, 
              style: ElevatedButton.styleFrom(
                elevation: 5, 
                backgroundColor: const Color(0xff636AF2),
                iconColor: Colors.black, 
                disabledBackgroundColor: Colors.black,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Iniciar sesion', style: TextStyle(
                    color: Colors.black
                   ),
                  ), 
                  Icon(Icons.arrow_right)
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Align(
              alignment: Alignment.center,
              child: Text('O', style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,  
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: () async {
                google();
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder:(context) => Home()));
                  logger.i('Exito');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingreso con google'),
                  ),
                );
              }, 
              style: ElevatedButton.styleFrom(
                elevation: 5, 
                backgroundColor: const Color.fromARGB(255, 116, 242, 99),
                iconColor: Colors.black, 
                disabledBackgroundColor: Colors.black,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.network('https://cdn4.iconfinder.com/data/icons/logos-brands-7/512/google_logo-google_icongoogle-512.png', width: 1, height: 1,),
                  const Text('Iniciar con Google', style: TextStyle(
                    color: Colors.black
                   ),
                  ), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}