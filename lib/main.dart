import 'package:flutter/material.dart';
import 'package:kassa/start/splash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kassa Apps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Rubik',
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xFFF2F2F7),
        backgroundColor: Colors.white,
        primarySwatch: Colors.green,
        primaryColor: Colors.green[700],
        accentColor: Colors.green[700],
        buttonColor: Colors.green[700],
        dialogBackgroundColor: Colors.white,
        textSelectionHandleColor: Colors.greenAccent[400],
        cursorColor: Colors.greenAccent[400],
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          brightness: Brightness.dark,
          elevation: 5.0,
          shadowColor: Colors.grey[700].withAlpha(50),
          color: Colors.green[700],
          iconTheme: IconThemeData(
            size: 20.0,
            color: Colors.grey[100],
          ),
          textTheme: TextTheme(
            title: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontFamily: 'Google2',
            )
          )
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: TextStyle(
            fontSize: 16.0,
            fontFamily: 'Google2'
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 16.0,
            fontFamily: 'Google2'
          ),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              width: 4.0,
              color: Colors.white,
            )
          )
        ),
        iconTheme: IconThemeData(
          size: 20.0,
          color: Color(0xFF5E6367)
        ),
        textTheme: TextTheme(
          headline1: TextStyle(
            color: Color(0xFF303437)
          ),
          headline2: TextStyle(
            color: Color(0xFF303437)
          ),
          headline3: TextStyle(
            color: Color(0xFF303437)
          ),
          headline4: TextStyle(
            color: Color(0xFF303437)
          ),
          headline5: TextStyle(
            color: Color(0xFF303437)
          ),
          headline6: TextStyle(
            color: Color(0xFF303437)
          ),
          subtitle1: TextStyle(
            color: Color(0xFF303437)
          ),
          subtitle2: TextStyle(
            color: Color(0xFF303437)
          ),
          bodyText1: TextStyle(
            color: Color(0xFF303437)
          ),
          bodyText2: TextStyle(
            color: Color(0xFF303437)
          ),
          caption: TextStyle(
            color: Color(0xFF6E7377)
          ),
          overline: TextStyle(
            color: Color(0xFF000000).withOpacity(0.3)
          ),
          button: TextStyle(
            fontFamily: 'Google2',
            fontSize: 15.0,
          )
        )
      ),
      home: SplashPage(),
    );
  }
}

