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

  //5.1 Controles para manipular el texto escrito
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  //5.2 Errores para mostrar en la UI
  String? _emailError;
  String? _passError;

  //2.1 Crear variables para focusNode
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  //5.3 Validadores
  bool isValidEmail(String email) {
    final regularExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regularExp.hasMatch(email);
  }

  bool isValidPassword(String pass) {
    final regularExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$',
    );
    return regularExp.hasMatch(pass);
  }

  //5.4 Acción al botón de login
  void _onLogin() {
    // De lo que escribió el usuario, quitar los espacios en blanco al inicio y al final
    final email = _emailController.text.trim();
    final pass = _passController.text.trim();

    //Reclutar emailError
    final emailMsgError = isValidEmail(email) ? null : 'Email inválido';
    final passMsgError = isValidPassword(pass)
        ? null
        : " 8 carcateres min, 1mayus, 1 minus, 1 número y carcater especial";

    // 5.5 Notificar cambios
    setState(() {
      _emailError = emailMsgError;
      _passError = passMsgError;
    });

    //5.6 Cerrar el teclado y bajar las manos
    FocusScope.of(context).unfocus();
    _typingDebbunce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.0;

    //5.7 Activar los Trigger
    if (emailMsgError == null && passMsgError == null) {
      _trigSuccess?.fire();
    } else {
      _trigFail?.fire();
    }
  }

  @override
  void initState() {
    super.initState();
    // 2.2 Listeners (Oyentes/Chismosos)
    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus) {
        // No tapes los ojos al ver email
        if (_isHandsUp != null) {
          _isHandsUp!.change(false);
          //3.2 miarada neutral
          _numLook?.value = 50;
        }
      }
    });
    _passwordFocus.addListener(() {
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
                //5.8 Enlazar controles
                controller: _emailController,
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
                  //5.9 Mostrar el texto de error
                  hintText: 'email',
                  errorText: _emailError,
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
                //5.8 Enlazar controles
                controller: _passController,
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
                  errorText: _passError,
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
              const SizedBox(height: 10),
              MaterialButton(
                //Toma todo el ancho posible
                minWidth: double.infinity,
                height: 50,
                color: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ), //RounderRectanleBorder
                onPressed: _onLogin,
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
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
    //5.10 Liberar Controles
    _emailController.dispose();
    _passController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _controller?.dispose();
    _typingDebbunce?.cancel();
    super.dispose();
  }
}
