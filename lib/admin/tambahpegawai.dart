import 'package:flutter/material.dart';

class TambahPegawaiPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return TambahPegawaiState();
  }

}

class TambahPegawaiState extends State{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget> [
              SliverAppBar(
                title: Text(
                  'Add Employee'
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