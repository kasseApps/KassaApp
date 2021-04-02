import 'dart:async';
import 'package:animations/animations.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kassa/admin/homeadmin.dart';
import 'package:kassa/pegawai/homepegawai.dart';
import 'package:kassa/start/buatpassword.dart';
import 'package:kassa/start/daftartoko.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }

}

class LoginState extends State{

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final Firestore firestore = Firestore.instance;
  final emailController =  TextEditingController();
  final passController =  TextEditingController();
  bool buttonActive = false, obscure = true, readOnly = false, loading = false, heperEmailError = false, heperPasswordError = false, rememberMe = false;
  String helperEmailErrorText, helperPasswordErrorText;

  @override
  void initState() {
    super.initState();
  }

  _checkUser() async {
    bool registered = false, setup = false;
    String id, foto, nama, alamat, kategori, noizin, telepon, password, idtoko;
    int role = 0;
    await firestore.collection('users').where('email',isEqualTo: emailController.text).getDocuments().then((value){
      if(value.documents.isNotEmpty){
        registered = true;
        value.documents.forEach((f) {
          id = f.documentID;
          if(f.data['role'] == 10){
            nama = f.data['namatoko'];
            kategori = f.data['kategoritoko'];
            noizin = f.data['noizin'];
            telepon = f.data['nomortelepon'];
            password = f.data['katasandi'];
          } else {
            idtoko = f.data['toko'];
            foto = f.data['foto'];
            nama = f.data['nama'];
            telepon = f.data['telepon'];
            password = f.data['password'];
            setup = f.data['setup'];
          }
          alamat = f.data['alamat'];
          role = f.data['role'];
        });
      }
    });
    if(mounted){
      if(registered){
        if(role == 10){
          if(passController.text == password){
            _loginApp(id, foto, nama, alamat, kategori, noizin, telepon, role, idtoko);
          } else {
            setState(() {
              loading = false;
              readOnly = false;
            });
            Flushbar(
              reverseAnimationCurve: Curves.decelerate,
              forwardAnimationCurve: Curves.decelerate,
              flushbarPosition: FlushbarPosition.BOTTOM,
              flushbarStyle: FlushbarStyle.FLOATING,
              isDismissible: false,
              backgroundColor: Colors.red[600],
              duration: Duration(seconds: 3),
              borderRadius: 10.0,
              margin: EdgeInsets.all(16.0),
              animationDuration: Duration(milliseconds: 300),
              icon: Icon(
                Icons.info_outline_rounded,
                color: Colors.white,
              ),
              messageText: Text(
                'Password does not match!',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  color: Colors.white,
                ),
              ),
            ).show(context);
          }
        } else {
          if(setup){
            if(passController.text == password){
              _loginApp(id, foto, nama, alamat, kategori, noizin, telepon, role, idtoko);
            } else {
              setState(() {
                loading = false;
                readOnly = false;
              });
              Flushbar(
                reverseAnimationCurve: Curves.decelerate,
                forwardAnimationCurve: Curves.decelerate,
                flushbarPosition: FlushbarPosition.BOTTOM,
                flushbarStyle: FlushbarStyle.FLOATING,
                isDismissible: false,
                backgroundColor: Colors.red[600],
                duration: Duration(seconds: 3),
                borderRadius: 10.0,
                margin: EdgeInsets.all(16.0),
                animationDuration: Duration(milliseconds: 300),
                icon: Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                ),
                messageText: Text(
                  'Password does not match!',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    color: Colors.white,
                  ),
                ),
              ).show(context);
            }
          } else {
            if(passController.text == password){
              setState(() {
                loading = false;
                readOnly = false;
              });
              Navigator.of(context).push(_sharedAxisRoute(BuatPasswordPage(id: id, foto: foto, nama: nama, email: emailController.text, alamat: alamat, telepon: telepon, role: role, idtoko: idtoko,), SharedAxisTransitionType.horizontal));
            } else {
              setState(() {
                loading = false;
                readOnly = false;
              });
              Flushbar(
                reverseAnimationCurve: Curves.decelerate,
                forwardAnimationCurve: Curves.decelerate,
                flushbarPosition: FlushbarPosition.BOTTOM,
                flushbarStyle: FlushbarStyle.FLOATING,
                isDismissible: false,
                backgroundColor: Colors.red[600],
                duration: Duration(seconds: 3),
                borderRadius: 10.0,
                margin: EdgeInsets.all(16.0),
                animationDuration: Duration(milliseconds: 300),
                icon: Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                ),
                messageText: Text(
                  'Password does not match!',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    color: Colors.white,
                  ),
                ),
              ).show(context);
            }
          }
        }
      } else {
        setState(() {
          loading = false;
          readOnly = false;
        });
        Flushbar(
          reverseAnimationCurve: Curves.decelerate,
          forwardAnimationCurve: Curves.decelerate,
          flushbarPosition: FlushbarPosition.BOTTOM,
          flushbarStyle: FlushbarStyle.FLOATING,
          isDismissible: false,
          backgroundColor: Colors.red[600],
          duration: Duration(seconds: 3),
          borderRadius: 10.0,
          margin: EdgeInsets.all(16.0),
          animationDuration: Duration(milliseconds: 300),
          icon: Icon(
            Icons.info_outline_rounded,
            color: Colors.white,
          ),
          messageText: Text(
            'Your email address not registered!',
            style: TextStyle(
              fontFamily: 'Rubik',
              color: Colors.white,
            ),
          ),
        ).show(context);
      }
    }
  }

  Future<FirebaseUser> _loginApp(String id, String foto, String nama, String alamat, String kategori, String noizin, String telepon, int role, String idtoko) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    try {
      FirebaseUser user = (await firebaseAuth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passController.text
        )
      ).user;

      assert(user != null);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await firebaseAuth.currentUser();
      if (user.uid == currentUser.uid) {
        preferences.setString('idUser', id);
        preferences.setString('fotoUser', foto);
        preferences.setString('nameUser', nama);
        preferences.setString('emailUser', emailController.text);
        preferences.setString('addressUser', alamat);
        if(role == 10){
          preferences.setString('categoryUser', kategori);
          preferences.setString('licenseUser', noizin);
        } else {
          preferences.setString('idToko', idtoko);
        }
        preferences.setString('phoneUser', telepon);
        preferences.setInt('roleUser', role);
        setState(() {
          loading = false;
          readOnly = false;
        });
        if(role == 10){
          Navigator.of(context).pushReplacement(_sharedAxisRoute(HomePage(), SharedAxisTransitionType.horizontal));
        } else {
          Navigator.of(context).pushReplacement(_sharedAxisRoute(HomePegawaiPage(), SharedAxisTransitionType.horizontal));
        }
      }
      return user;
    } catch (e) {
      print('Error Login: $e');
      setState(() {
        loading = false;
        readOnly = false;
      });
      Flushbar(
        reverseAnimationCurve: Curves.decelerate,
        forwardAnimationCurve: Curves.decelerate,
        flushbarPosition: FlushbarPosition.BOTTOM,
        flushbarStyle: FlushbarStyle.FLOATING,
        isDismissible: false,
        backgroundColor: Colors.red[600],
        duration: Duration(seconds: 3),
        borderRadius: 10.0,
        margin: EdgeInsets.all(16.0),
        animationDuration: Duration(milliseconds: 300),
        icon: Icon(
          Icons.info_outline_rounded,
          color: Colors.white,
        ),
        messageText: Text(
          '$e',
          style: TextStyle(
            fontFamily: 'Rubik',
            color: Colors.white,
          ),
        ),
      ).show(context);
      return null;
    }
  }

  _enableButton(){
    if (emailController.text.length > 0){
      if(validateEmail(emailController.text)){
        setState(() {
          helperEmailErrorText = null;
          heperEmailError = false;
        });
        if(passController.text.length > 5){
          setState(() {
            helperPasswordErrorText = null;
            heperPasswordError = false;
            buttonActive = true;
          });
        } else {
          setState(() {
            helperPasswordErrorText = 'Minimum password is 6 characters!';
            heperPasswordError = true;
            buttonActive = false;
          });
        }
      } else {
        setState(() {
          helperEmailErrorText = 'Invalid email address!';
          heperEmailError = true;
          buttonActive = false;
        });
      }
    } else {
      setState(() {
        helperEmailErrorText = 'Enter your email address!';
        heperEmailError = true;
        buttonActive = false;
      });
    }
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value) || value == null){
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget> [
            SliverAppBar(
              primary: true,
              pinned: true,
              leading: IconButton(
                icon: Icon(
                  Icons.close_rounded,
                ),
                onPressed: (){

                },
              ),
              title: Text(
                'Login Kassa'
              ),
              centerTitle: true,
            )
          ];
        },
        body: GestureDetector(
          onTap: (){
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Theme.of(context).backgroundColor,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 16.0, bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/login.png',
                          width: MediaQuery.of(context).size.width * 0.45,
                        ),
                      ),
                      SizedBox(
                        height: 50.0,
                      ),
                      Text(
                        'Email Address',
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      TextFormField(
                        controller: emailController,
                        readOnly: readOnly,
                        onChanged: (value){
                          _enableButton();
                        },
                        decoration: InputDecoration(
                          hintText: 'example@example.com',
                          counter: Offstage(),
                          helperText: heperEmailError ? helperEmailErrorText : null,
                          helperStyle: TextStyle(
                            color: heperEmailError ? Colors.red : null,
                          ),
                          filled: true,
                          fillColor: heperEmailError ? Colors.red[50] : null,
                          disabledBorder: UnderlineInputBorder(      
                            borderSide: BorderSide(
                              color: heperEmailError ? Colors.red : Theme.of(context).disabledColor,
                            )   
                          ),
                          enabledBorder: UnderlineInputBorder(      
                            borderSide: BorderSide(
                              color: heperEmailError ? Colors.red : Theme.of(context).disabledColor,
                            )   
                          ),  
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: heperEmailError ? Colors.red : Theme.of(context).accentColor,
                            )
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: heperEmailError ? Colors.red : Theme.of(context).accentColor,
                            )
                          )
                        ),
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                        ),
                        maxLength: 50,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      Text(
                        'Password',
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      TextFormField(
                        controller: passController,
                        readOnly: readOnly,
                        obscureText: obscure,
                        onChanged: (value){
                          _enableButton();
                        },
                        decoration: InputDecoration(
                          hintText: '*******',
                          counter: Offstage(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded
                            ), 
                            onPressed: (){
                              setState(() {
                                obscure = !obscure;
                              });
                            }
                          ),
                          helperText: heperPasswordError ? helperPasswordErrorText : null,
                          helperStyle: TextStyle(
                            color: heperPasswordError ? Colors.red : null,
                          ),
                          filled: true,
                          fillColor: heperPasswordError ? Colors.red[50] : null,
                          disabledBorder: UnderlineInputBorder(      
                            borderSide: BorderSide(
                              color: heperPasswordError ? Colors.red : Theme.of(context).disabledColor,
                            )   
                          ),
                          enabledBorder: UnderlineInputBorder(      
                            borderSide: BorderSide(
                              color: heperPasswordError ? Colors.red : Theme.of(context).disabledColor,
                            )   
                          ),  
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: heperPasswordError ? Colors.red : Theme.of(context).accentColor,
                            )
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: heperPasswordError ? Colors.red : Theme.of(context).accentColor,
                            )
                          )
                        ),
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                        ),
                        maxLength: 20,
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      Row(
                        children: [
                          Text(
                            'Forgot your account password?',
                          ),
                          SizedBox(width: 3.0,),
                          GestureDetector(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: Text(
                                'Get help here',
                                style: TextStyle(
                                  fontFamily: 'Google2'
                                ),
                              ),
                            ),
                            onTap: (){

                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Divider(
                        thickness: 1.0,
                        height: 1.0,
                      ),
                      Container(
                        color: Theme.of(context).backgroundColor,
                        padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 16.0, bottom: 16.0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 50.0,
                              child: FlatButton(
                                onPressed: buttonActive && !loading ? (){
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                  setState(() {
                                    readOnly = true;
                                    loading = true;
                                  });
                                  _checkUser();
                                } : (){}, 
                                child: loading ? CupertinoActivityIndicator() : Text(
                                  'Login Now'
                                ),
                                textColor: Colors.white,
                                color: buttonActive && !loading ? Theme.of(context).buttonColor : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Open your store?'
                                ),
                                SizedBox(width: 3.0,),
                                GestureDetector(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                    child: Text(
                                      'Resgister now',
                                      style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                        fontFamily: 'Google2'
                                      ),
                                    ),
                                  ),
                                  onTap: (){
                                    Navigator.of(context).push(_sharedAxisRoute(DaftarTokoPage(), SharedAxisTransitionType.horizontal));
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Route _sharedAxisRoute(Widget destination, SharedAxisTransitionType type) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          child: child,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: type,
          fillColor: Theme.of(context).backgroundColor,
        );
      },
    );
  }

}