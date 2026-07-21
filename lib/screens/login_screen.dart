import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; //4.1 Para poner timer

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  //Control para mostrar/ocultar contraseña
  bool _obscureText = true;

  // Cerebro de la animación
  StateMachineController? _controller;
  //State machine input para controlar la animación
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  //3.1 Varibales para recorrerla mirada 
  SMINumber? _numLook;

  //4.2 timer oara detener la mirada al dejar de escribir
  Timer? _typingDebbunce;

  //2.1 Crear variables para focusNode
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();


  @override
  void initState() {
    super.initState();
    // 2.2 Listeners (Oyentes/Chismosos)
    _emailFocus.addListener((){
      if (_emailFocus.hasFocus) {
        // No tapes los ojos al ver email
        if (_isHandsUp != null) {
          _isHandsUp!.change(false);
          //3.2 miarada neutral
          _numLook?.value = 50;
        }
      }
    });
    _passwordFocus.addListener((){
      //Mano arriba en password
      _isHandsUp?.change(_passwordFocus.hasFocus);
    });
  }

  //Para obtener el tamaño de la pantalla
  @override
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
                child: RiveAnimation.asset(
                  'assets/animated_login_bear.riv',
                  stateMachines: const ['Login Machine'],
                  // Al iniciar la animación, se ejecuta el callback onInit
                  onInit: (artboard) {
                    _controller = StateMachineController.fromArtboard(
                        artboard, 'Login Machine');
                    //verifica que inició bien
                    if (_controller == null) return;
                    //Agregar el controlador al tablero
                    artboard.addController(_controller!);
                    //Vincular variables
                    _isChecking = _controller?.findSMI('isChecking');
                    _isHandsUp = _controller?.findSMI('isHandsUp');
                    _trigSuccess = _controller?.findSMI('trigSuccess');
                    _trigFail = _controller?.findSMI('trigFail');
                    //3.3 Vincular numlook
                    _numLook = _controller?.findSMI('numLook');
                  },
                ),
              ),
              // para separar elementos
              const SizedBox(height: 10),
              // campo de texto para el correo electrónico
              TextField(
                focusNode: _emailFocus,
                //1.3 vincular SMI´s a inputs de UI
                onChanged: (value) {
                  //No tapes los ojos al ver email
                  // if (_isHandsUp == null) return;
                  // _isHandsUp!.change(false);

                  //si isChecking es nulo
                  if (_isChecking == null) return;
                  //Activa el modo chismoso
                  _isChecking!.change(true);
                  //3.4 Implementar numLook
                  //Ajustar limnites de 0 a 100
                  //80 es la medida calibración
                  final look = (value.length / 80.0 * 100.0).clamp(
                    0.0,
                    100.0,
                  ); // clan es un rango. Traducción: abrazadera
                  _numLook?.value = look;

                  //4.3 Debbunce: si vuelve a teclear , reinicia el contador
                  //Cancelar cualquier timer existente
                  _typingDebbunce?.cancel();
                  //Crear timer
                  _typingDebbunce = Timer(const Duration(seconds: 3), () {
                    //Si se cierra la pantalla
                    if (!mounted) return;
                    // Miradaa neutral
                    _isChecking?.change(false);
                  });
                },
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
              const SizedBox(height: 10),
              // campo de texto para la contraseña
              TextField(
                focusNode: _passwordFocus,
                //1.4 vincular SMI´s a inputs de UI
                onChanged: (value) {
                  if (_isChecking != null) {
                    // No tapes los ojos al ver la contraseña
                    _isChecking!.change(false);
                  }
                  // //Si el isHandsUp es nulo
                  // if (_isHandsUp == null) return;
                  // //Activa el modo manos arriba
                  // _isHandsUp!.change(true);
                },
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
  //2.4 Libera recursos de la memoria
  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _controller?.dispose();
    _typingDebbunce?.cancel();
    super.dispose();
  }
}
