import 'package:flutter/material.dart';

class ListPerangkatPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ListPerangkatState();
  }

}

class ListPerangkatState extends State{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget> [
              SliverAppBar(
                title: Text(
                  'Devices'
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