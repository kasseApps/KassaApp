import 'package:flutter/material.dart';

class TambahProdukPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return TambahProdukState();
  }

}

class TambahProdukState extends State{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget> [
              SliverAppBar(
                title: Text(
                  'Add Product'
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