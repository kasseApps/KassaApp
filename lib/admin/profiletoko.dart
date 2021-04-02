import 'package:flutter/material.dart';

class ProfilTokoPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ProfilTokoState();
  }

}

class ProfilTokoState extends State{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget> [
              SliverAppBar(
                title: Text(
                  'Store Profile'
                ),
              )
            ];
          },
          body: SingleChildScrollView(
            child: Column(
              children: [

              ],
            ),
          ),
        ),
      ),
    );
  }

}