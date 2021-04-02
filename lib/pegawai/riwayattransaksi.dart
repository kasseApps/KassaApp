import 'package:flutter/material.dart';

class RiwayatTransaksiPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return RiwayatTransaksiState();
  }

}

class RiwayatTransaksiState extends State{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget> [
              SliverAppBar(
                title: Text(
                  'Transaction History'
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