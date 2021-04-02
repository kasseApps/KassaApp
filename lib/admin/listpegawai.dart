import 'package:flutter/material.dart';

class ListPegawaiPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ListPegawaiState();
  }

}

class ListPegawaiState extends State{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget> [
              SliverAppBar(
                title: Text(
                  'Employees'
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