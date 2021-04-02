import 'package:flutter/material.dart';

class DetailTransaksiPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return DetailTransaksiState();
  }

}

class DetailTransaksiState extends State{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget> [
              SliverAppBar(
                title: Text(
                  'Transaction Detail'
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