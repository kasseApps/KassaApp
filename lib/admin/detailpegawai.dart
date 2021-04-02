import 'package:flutter/material.dart';

class DetailPegawaiPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return DetailPegawaiState();
  }

}

class DetailPegawaiState extends State{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget> [
              SliverAppBar(
                title: Text(
                  'Employee Details'
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