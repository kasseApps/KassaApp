import 'package:flutter/material.dart';

class RiwayatTransaksiPegawaiPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return RiwayatTransaksiPegawaiState();
  }

}

class RiwayatTransaksiPegawaiState extends State{
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