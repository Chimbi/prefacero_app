import 'dart:async';
import 'dart:ui';
//import 'package:appsolidariav3/model/polizaModel.dart';
import 'package:prefacero_app/model/order.dart';
import 'package:prefacero_app/model/user.dart';
import 'package:prefacero_app/utils/db.dart';
import 'package:prefacero_app/screens/inicio.dart';
import 'package:prefacero_app/utils/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
//import 'package:rxdart/rxdart.dart';

enum AuthMode { Signup, Login }

//Variables de la funcion autenticar
FirebaseUser _authenticatedUser;
Timer _authTimer;
String _selProductId;

final Firestore _db = Firestore.instance;
final AuthService auth = AuthService();

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {


  @override
  void initState() {
    super.initState();
    if(_authenticatedUser!=null){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => PaginaInicio()));
    }
  }

  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
    'acceptTerms': true
  };
  final _username = TextEditingController();
  final _password = TextEditingController();

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>(); //Para que se utiliza?

  final AuthService auth = AuthService();

  //Por defecto authMode es Login
  AuthMode _authMode = AuthMode.Login;

  Widget loginBtn() {
    var polizaObj = Provider.of<Order>(context);
    return Row(children: <Widget>[
      Expanded(
        flex: 1,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 4.0,
          color: Theme.of(context).accentColor,
          child: Text(
            _authMode == AuthMode.Login ? "INGRESAR" : "REGISTRO",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
//                    Retorna un Future que debo hacer para seleccionar un int
//                    int resultado=bloc.getPassword("correo='"+_username.text.trim()+"' and password='"+_password.text.trim()+"' ");

            _submitForm(authenticate);
/*
            int resultado = 1;

            if (resultado == 0) {
              Fluttertoast.showToast(
                  msg: "Error, reintente nuevamente " + resultado.toString(),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIos: 2,
//                          backgroundColor: Colors.red,
//                          textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              CircularProgressIndicator();
             }
           Navigator.pop(context);
*/



          },
        ),
      ),
    ]);
  }

  Widget ResetBtn() {
    return Row(children: <Widget>[
      Expanded(
        flex: 1,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 4.0,
          color: Theme.of(context).buttonColor,
          child: Text(
            "REESTABLECER CONTRASEÑA",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            CircularProgressIndicator();
          },
        ),
      ),
    ]);
  }

  Widget _buildAcceptSwitch() {
    return SwitchListTile(
      value: _formData['acceptTerms'],
      onChanged: (bool value) {
        setState(() {
          _formData['acceptTerms'] = value;
        });
      },
      title: Text('Acepto Términos'),
    );
  }

  void _submitForm(Function authenticate) async {
    var polizaObj = Provider.of<Order>(context);
    if (!_formKey.currentState.validate() || !_formData['acceptTerms']) {
      if(!_formData['acceptTerms']){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Ha ocurrido un error!'),
              content: Text("Por favor aceptar términos"),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
        return;
      }else return;
    }
    _formKey.currentState.save();
    Map<String, dynamic> successInformation;
    successInformation = await authenticate(_formData['email'], _formData['password'], _authMode);
    if (successInformation['success']) {

      //print("PolizaObj.intermediary: ${polizaObj.intermediary.toString()}");
      /*
      try {
        //polizaObj.intermediary = await DatabaseService().intermediarioInit();
        //polizaObj.notifyListeners();
      }catch (error){
        print("Error en intermediario");
        //polizaObj.intermediary = null;
        //Intermediary creation page
      };
      */

      Navigator.pushNamed(context, '/inicio');
      //TODO forma insegura para ingreso, cambiar por dirección de la ventana


      /*
      Fluttertoast.showToast(
          msg: "Bienvenido...", //+ resultado.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 2,
          fontSize: 16.0);
      */

      // Navigator.pushReplacementNamed(context, '/');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Ha ocurrido un error!'),
            content: Text(successInformation['message']),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    }
  }

  Widget loginForm() {
    return Column(
      children: <Widget>[
        SizedBox(height: 1.0),
        Text(
          _authMode == AuthMode.Signup ? "Ventana de Registro" : "Ingreso",
          textScaleFactor: 2.0,
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _username,
                validator: (String value) {
                  if (value.isEmpty ||
                      !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                          .hasMatch(value)) {
                    return 'Por favor ingresar un correo valido';
                  } return null;
                },
                onSaved: (String value) {
                  _formData['email'] = value;
                },
                decoration: InputDecoration(
                  labelText: 'Correo',
                  labelStyle: TextStyle(color: Theme.of(context).hintColor),
                ),
                focusNode: _usernameFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (term) {
                  _usernameFocus.unfocus();
                  FocusScope.of(context).requestFocus(_passwordFocus);
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _password,
                validator: (String value) {
                  if (value.isEmpty || value.length < 6) {
                    return 'Contraseña muy corta';
                  } return null;
                },
                onSaved: (String value) {
                  _formData['password'] = value;
                },
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(color: Theme.of(context).hintColor),
                ),
                focusNode:_passwordFocus,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  WhitelistingTextInputFormatter.digitsOnly,
                ],
                obscureText: true,
              ),
              _authMode == AuthMode.Signup ? TextFormField(
                decoration: InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  labelStyle: TextStyle(color: Theme.of(context).hintColor),
                ),
                obscureText: true,
                keyboardType: TextInputType.phone,
                validator: (String value) {
                  if (_password.text != value &&
                      _authMode == AuthMode.Signup) {
                    return 'Contraseña no concuerda.';
                  } return null;
                },
              ) : Container()
            ],
          ),
        ),
        SizedBox(height: 12.0),
        loginBtn(),
        ResetBtn(),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor: Colors.white,
      key: scaffoldKey,
      body: ListView(
        children: <Widget>[
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                "assets/logo.png",
                scale: 0.9,
                height: 180,
                width: 500,
              ),
            ),
          ),
          Container(
            child: Center(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        loginForm(),
                        SizedBox(height: 12.0),
                        //_buildAcceptSwitch(),
                        FlatButton(
                          child: Text(
                              '${_authMode == AuthMode.Login ? 'Deseo registrarme' : 'Ya tengo contraseña'}'),
                          onPressed: () {
                            if (_authMode == AuthMode.Login) {
                              setState(() {
                                _authMode = AuthMode.Signup;
                              });
                            } else {
                              setState(() {
                                _authMode = AuthMode.Login;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    height: 500.0,
                    width: 320.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        color: Colors.grey.shade200.withOpacity(0.5)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//----------------Debería ir en el bloc -------------------------
//TODO implementar el bloc e incluir estos metodos ahí
Future<Map<String, dynamic>> authenticate(String email, String password,
    [AuthMode mode = AuthMode.Login]) async {

  AuthResult result;
  PlatformException errorAuth;

  //Ingresar
  if (mode == AuthMode.Login) {
    try{
      result = await auth.signInPassword(email, password);
    } catch(error){
      errorAuth = error;
      print("result ${errorAuth.code}");
    }
    /*
    response = await http.post(
      'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyCIJNUjRXveaBTneXInGpmE7XsOKSHKpGY',
      body: json.encode(authData),
      headers: {'Content-Type': 'application/json'},);
    */
  } else {
    //Crear cuenta
    try{
      result = await auth.createUser(email,password);
      print("result on create $result");
    }catch(error){
      errorAuth = error;
      print("error on create $error");
    }

    /*
    response = await http.post(
      'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyCIJNUjRXveaBTneXInGpmE7XsOKSHKpGY',
      body: json.encode(authData),
      headers: {'Content-Type': 'application/json'},);
      */
  }


  //final Map<String, dynamic> responseData = json.decode(response.body);
  bool hasError = true;
  String message = 'Algo salió mal.';
  //print("ResponseData: $responseData");
  if (result != null) {
    hasError = false;
    message = 'Autenticación satisfactoria!';
    _authenticatedUser = await result.user;

    //setAuthTimeout(int.parse(responseData['expiresIn']));
    //_userSubject.add(true);
    //final DateTime now = DateTime.now();
    //final DateTime expiryTime = now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
    /*
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', responseData['idToken']);
    prefs.setString('userEmail', email);
    prefs.setString('userId', responseData['localId']);
    prefs.setString('expiryTime', expiryTime.toIso8601String());
    updateUserData(_authenticatedUser);
    */
  } else if (errorAuth?.code == 'EMAIL_EXISTS') {
    message = 'El e-mail ya existe.';
  } else if (errorAuth?.code == 'EMAIL_NOT_FOUND') {
    message = 'E-mail no encontrado.';
  } else if (errorAuth?.code == 'INVALID_PASSWORD') {
    message = 'La contraseña es invalida.';
  } else if (errorAuth?.code == 'ERROR_WRONG_PASSWORD') {
    message = 'La contraseña esta errada.';
  } else if (errorAuth?.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
    message = 'E-mail ya registrado.';
  } else if (errorAuth?.code == 'ERROR_USER_NOT_FOUND') {
    message = 'Usuario no registrado.';
  } else if (errorAuth?.code == 'ERROR_NETWORK_REQUEST_FAILED') {
    message = 'Por favor revise su conexión a internet.';
  }






  //_isLoading = false;
  //notifyListeners();
  return {'success': !hasError, 'message': message};
}



