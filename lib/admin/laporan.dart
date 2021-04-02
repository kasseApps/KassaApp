import 'package:flutter/material.dart';

class LaporanPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return LaporanState();
  }

}

class LaporanState extends State{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget> [
            SliverAppBar(
              pinned: true,
              primary: true,
              title: Text(
                'Report'
              ),
              centerTitle: true,
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
    );
  }

}