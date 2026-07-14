import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  //Control para mostrar/ocuiltar contraseña
  bool _obscureText = true;
  @override

  //Para obtener el tamaño de la pantalla
   Widget build(BuildContext context) {
  final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: const RiveAnimation.asset('assets/animated_login_bear.riv'),
              ),
              // para separar elementos
              SizedBox(height: 10),
              // campo de texto para el correo electrónico
              TextField(
                // para mostrar un tipo de teclado
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    //Parametro borde redondeado
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),   
                
              ),
              SizedBox(height: 10),
              // campo de texto para la contraseña
              TextField(
                    obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: 'password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}