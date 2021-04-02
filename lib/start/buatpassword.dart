import 'package:animations/animations.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kassa/pegawai/homepegawai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuatPasswordPage extends StatefulWidget {

  final String id, foto, nama, email, alamat, telepon, idtoko;
  final int role;

  const BuatPasswordPage({Key key, @required this.id, @required this.foto, @required this.nama, @required this.email, @required this.alamat, @required this.telepon, @required this.role, @required this.idtoko,}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BuatPasswordState();
  }

}

class BuatPasswordState extends State<BuatPasswordPage> {

  final Firestore firestore = Firestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final newpassController = TextEditingController();
  final confirmpassController = TextEditingController();
  bool readOnly = false, heperNewPassError = false, heperConfirmError = false, obscureNewpass = true, obscureConfirm = true, buttonActive = false, loading = false;
  String heperNewPassErrorText, heperConfirmErrorText;

  _enableButton(){
    if(newpassController.text.length > 5){
      setState(() {
        heperNewPassErrorText = null;
        heperNewPassError = false;
      });
      if(confirmpassController.text == newpassController.text){
        setState(() {
          heperConfirmErrorText = null;
          heperConfirmError = false;
          buttonActive = true;
        });
      } else {
        setState(() {
          heperConfirmErrorText = 'Password confirmation does not match!';
          heperConfirmError = true;
          buttonActive = false;
        });
      }
    } else {
      setState(() {
        heperNewPassErrorText = 'Minimum password is 6 characters!';
        heperNewPassError = true;
        buttonActive = false;
      });
    }
  }

  _registerAuth() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    try {
      FirebaseUser user = (await firebaseAuth.createUserWithEmailAndPassword(
          email: widget.email,
          password: confirmpassController.text,
        )
      ).user;

      assert(user != null);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await firebaseAuth.currentUser();
      if (user.uid == currentUser.uid) {
        firestore.collection('users').document(widget.id).updateData({
          'password': newpassController.text,
          'setup': true,
        });
        preferences.setString('idUser', widget.id);
        preferences.setString('fotoUser', widget.foto);
        preferences.setString('nameUser', widget.nama);
        preferences.setString('emailUser', widget.email);
        preferences.setString('addressUser', widget.alamat);
        preferences.setString('idToko', widget.idtoko);
        preferences.setString('phoneUser', widget.telepon);
        preferences.setInt('roleUser', widget.role);
        Navigator.of(context).pushAndRemoveUntil(_sharedAxisRoute(HomePegawaiPage(), SharedAxisTransitionType.horizontal), (Route<dynamic> route) => false);
      }
    } catch (e) {
      print('Error Login: $e');
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget> [
            SliverAppBar(
              primary: true,
              pinned: true,
              title: Text(
                'Create new password'
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
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 30.0, bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  blurRadius: 10.0,
                                  color: Theme.of(context).dividerColor,
                                  offset: Offset(1.0, 1.0),
                                )
                              ]
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: CachedNetworkImage(
                                imageUrl: widget.foto,
                                width: MediaQuery.of(context).size.width * 0.18,
                                height: MediaQuery.of(context).size.width * 0.18,
                                fit: BoxFit.cover,
                                progressIndicatorBuilder: (context, url, downloadProgress){ 
                                  return Center(
                                    child: CupertinoActivityIndicator(),
                                  );
                                },
                                errorWidget: (context, url, error){
                                  return Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 30.0,
                                    ),
                                  );
                                }
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Center(
                          child: Text(
                            widget.nama,
                            style: TextStyle(
                              fontFamily: 'Google2',
                              fontSize: Theme.of(context).textTheme.headline6.fontSize,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Center(
                          child: Text(
                            widget.email,
                          ),
                        ),
                        SizedBox(
                          height: 50.0,
                        ),
                        Text(
                          'New password',
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        TextFormField(
                          controller: newpassController,
                          readOnly: readOnly,
                          obscureText: obscureNewpass,
                          onChanged: (value){
                            _enableButton();
                          },
                          decoration: InputDecoration(
                            hintText: '*******',
                            counter: Offstage(),
                            helperText: heperNewPassError ? heperNewPassErrorText : null,
                            helperStyle: TextStyle(
                              color: heperNewPassError ? Colors.red : null,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureNewpass ? Icons.visibility_off_rounded : Icons.visibility_rounded
                              ), 
                              onPressed: (){
                                setState(() {
                                  obscureNewpass = !obscureNewpass;
                                });
                              }
                            ),
                            filled: true,
                            fillColor: heperNewPassError ? Colors.red[50] : null,
                            disabledBorder: UnderlineInputBorder(      
                              borderSide: BorderSide(
                                color: heperNewPassError ? Colors.red : Theme.of(context).disabledColor,
                              )   
                            ),
                            enabledBorder: UnderlineInputBorder(      
                              borderSide: BorderSide(
                                color: heperNewPassError ? Colors.red : Theme.of(context).disabledColor,
                              )   
                            ),  
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: heperNewPassError ? Colors.red : Theme.of(context).accentColor,
                              )
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: heperNewPassError ? Colors.red : Theme.of(context).accentColor,
                              )
                            )
                          ),
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                          ),
                          maxLength: 15,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        Text(
                          'Confirm password',
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        TextFormField(
                          controller: confirmpassController,
                          readOnly: readOnly,
                          obscureText: obscureConfirm,
                          onChanged: (value){
                            _enableButton();
                          },
                          decoration: InputDecoration(
                            hintText: '*******',
                            counter: Offstage(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded
                              ), 
                              onPressed: (){
                                setState(() {
                                  obscureConfirm = !obscureConfirm;
                                });
                              }
                            ),
                            helperText: heperConfirmError ? heperConfirmErrorText : null,
                            helperStyle: TextStyle(
                              color: heperConfirmError ? Colors.red : null,
                            ),
                            filled: true,
                            fillColor: heperConfirmError ? Colors.red[50] : null,
                            disabledBorder: UnderlineInputBorder(      
                              borderSide: BorderSide(
                                color: heperConfirmError ? Colors.red : Theme.of(context).disabledColor,
                              )   
                            ),
                            enabledBorder: UnderlineInputBorder(      
                              borderSide: BorderSide(
                                color: heperConfirmError ? Colors.red : Theme.of(context).disabledColor,
                              )   
                            ),  
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: heperConfirmError ? Colors.red : Theme.of(context).accentColor,
                              )
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: heperConfirmError ? Colors.red : Theme.of(context).accentColor,
                              )
                            )
                          ),
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                          ),
                          maxLength: 15,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                      ],
                    ),
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
                                    loading = true;
                                    readOnly = true;
                                  });
                                  _registerAuth();
                                } : (){}, 
                                child: loading ? CupertinoActivityIndicator() : Text(
                                  'Save and start kasse'
                                ),
                                textColor: Colors.white,
                                color: buttonActive && !loading ? Theme.of(context).buttonColor : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ]
            )
          )
        )
      )
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