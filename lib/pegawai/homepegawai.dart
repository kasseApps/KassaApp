import 'package:flutter/material.dart';

class HomePegawaiPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return HomePegawaiState();
  }

}

class HomePegawaiState extends State{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget> [
              SliverAppBar(
                title: Text(
                  'Home'
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