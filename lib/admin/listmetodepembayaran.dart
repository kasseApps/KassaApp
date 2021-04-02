import 'package:flutter/material.dart';

class ListMetodePembayaranPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ListMetodePembayaranState();
  }

}

class ListMetodePembayaranState extends State{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget> [
              SliverAppBar(
                title: Text(
                  'Payment Methods'
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