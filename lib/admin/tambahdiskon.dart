import 'package:flutter/material.dart';

class TambahDiskonPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return TambahDiskonState();
  }

}

class TambahDiskonState extends State{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget> [
              SliverAppBar(
                title: Text(
                  'Add Discount'
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