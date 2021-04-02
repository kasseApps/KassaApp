import 'dart:async';

import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kassa/admin/homeadmin.dart';
import 'package:kassa/pegawai/homepegawai.dart';
import 'package:kassa/start/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SpalashState();
  }

}

class SpalashState extends State {

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    _getCurrentUser();
    super.initState();
  }

  _getCurrentUser() async {
    FirebaseUser user = await firebaseAuth.currentUser();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if(user != null){
      int role = preferences.getInt('roleUser');
      if(role == 10){
        Timer(Duration(milliseconds: 1500), (){
          Navigator.of(context).pushReplacement(_sharedAxisRoute(HomePage(), SharedAxisTransitionType.horizontal));
        });
      } else if (role == 20){
        Timer(Duration(milliseconds: 1500), (){
          Navigator.of(context).pushReplacement(_sharedAxisRoute(HomePegawaiPage(), SharedAxisTransitionType.horizontal));
        });
      } 
      // else {
      //   Timer(Duration(milliseconds: 1500), (){
      //     Navigator.of(context).pushReplacement(_sharedAxisRoute(HomeAdmin(), SharedAxisTransitionType.horizontal));
      //   });
      // }
    }else{
      Timer(Duration(milliseconds: 1500), (){
        Navigator.of(context).pushReplacement(_sharedAxisRoute(LoginPage(), SharedAxisTransitionType.horizontal));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image.asset(
                  //   'assets/images/libera.png',
                  //   width: MediaQuery.of(context).size.width * 0.2,
                  // ),
                  // SizedBox(
                  //   height: 16.0,
                  // ),
                  Text(
                    'Kassa', 
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.headline4.fontSize,
                      fontFamily: 'Google2'
                    ),
                  ),
                ],
              )
            ),
            Positioned(
              bottom: 50.0,
              left: 0.0,
              right: 0.0,
              child: Center(
                child: Text('\u00a9 2021 Kassa',
                  style: Theme.of(context).textTheme.overline
                ),
              ),
            )
          ],
        ),
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