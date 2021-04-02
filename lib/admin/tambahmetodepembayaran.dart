import 'package:flutter/material.dart';

class TambahMetodePembayaranPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return TambahMetodePembayaranState();
  }

}

class TambahMetodePembayaranState extends State{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget> [
              SliverAppBar(
                title: Text(
                  'Add Payment Method'
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