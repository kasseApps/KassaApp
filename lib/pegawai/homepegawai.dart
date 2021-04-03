import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kassa/pegawai/riwayattransaksi.dart';
import 'package:kassa/pegawai/transaksi.dart';
import 'package:kassa/start/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePegawaiPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return HomePegawaiState();
  }

}

class MenuEmployee {
  final IconData icon;
  final String title;
  final int action;
  final Color color;

  MenuEmployee(this.icon, this.title, this.action, this.color);
}

class CategoryProduct {

  final String id, nama;

  CategoryProduct(this.id, this.nama);

  CategoryProduct.fromJson(Map<String, dynamic> jsonData) : id = jsonData['id'], nama = jsonData['nama'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
    };
  }
}

class HomePegawaiState extends State{

  final Firestore firestore = Firestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String idToko, fotoToko, namaToko, idUser, fotoUser, namaUser;
  List<MenuEmployee> listMenu = new List<MenuEmployee>();

  MenuEmployee menu1 = new MenuEmployee(Icons.shopping_basket_rounded, 'Transaction', 10, Colors.blue);
  MenuEmployee menu2 = new MenuEmployee(Icons.list_alt_rounded,'History transaction', 20, Colors.orange);
  MenuEmployee menu3 = new MenuEmployee(Icons.person,'My Account', 30, Colors.deepPurple);

  @override
  void initState() {
    listMenu.add(menu1);
    listMenu.add(menu2);
    listMenu.add(menu3);
    _getCurrentUsers();
    super.initState();
  }

  _getCurrentUsers() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idtoko = preferences.getString('idToko');
    String fototoko = preferences.getString('fotoToko');
    String namatoko = preferences.getString('namaToko');
    String iduser = preferences.getString('idUser');
    String fotouser = preferences.getString('fotoUser');
    String namauser = preferences.getString('nameUser');
    setState(() {
      idToko = idtoko;
      if(fototoko == null){
        fotoToko = 'https://firebasestorage.googleapis.com/v0/b/kassaapps-d7ece.appspot.com/o/store.jpeg?alt=media&token=e53fbe4f-029c-4972-8786-6afbae5a7c8e';
      } else {
        fotoToko = fototoko;
      }
      namaToko = namatoko;
      idUser = iduser;
      if(fotouser == null){
        fotoUser = 'https://firebasestorage.googleapis.com/v0/b/kassaapps-d7ece.appspot.com/o/avatar.jpeg?alt=media&token=42c653dd-405a-4a5f-92d0-d4e1692d452a';
      } else {
        fotoUser = fotouser;
      }
      namaUser = namauser;
    });
    _getCategoryProduct();
  }

  _getCategoryProduct() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<CategoryProduct> listProduct = new List<CategoryProduct>();
    await firestore.collection('users').document(idToko).collection('kategorimenu').getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) {
          CategoryProduct kategoriproduk = new CategoryProduct(f.documentID, f.data['nama']);
          listProduct.add(kategoriproduk);
        });
      }
    });
    if(mounted){
      if(listProduct.length > 0){
        preferences.setString('kategoriproduk', jsonEncode(listProduct));
      }
    }
  }

  String _getToday(){
    String todayIna;
    var date = DateTime.now();
    var dayFormat = DateFormat.EEEE();
    var todayEnglish = dayFormat.format(date);
    switch(todayEnglish){
      case 'Monday' : 
        todayIna = 'Senin';
      break;
      case 'Tuesday' : 
        todayIna = 'Selasa';
      break;
      case 'Wednesday' : 
        todayIna = 'Rabu';
      break;
      case 'Thursday' : 
        todayIna = 'Kamis';
      break;
      case 'Friday' : 
        todayIna = 'Jumat';
      break;
      case 'Saturday' : 
        todayIna = 'Sabtu';
      break;
      case 'Sunday' : 
        todayIna = 'Minggu';
      break;
    }
    return todayIna;
  }

  String _getNamaBulan(int bulan){
    String namaBulan;
    switch(bulan){
      case 1:
        namaBulan = 'Januari';
      break;
      case 2:
        namaBulan = 'Februari';
      break;
      case 3:
        namaBulan = 'Maret';
      break;
      case 4:
        namaBulan = 'April';
      break;
      case 5:
        namaBulan = 'Mei';
      break;
      case 6:
        namaBulan = 'Juni';
      break;
      case 7:
        namaBulan = 'Juli';
      break;
      case 8:
        namaBulan = 'Agustus';
      break;
      case 9:
        namaBulan = 'September';
      break;
      case 10:
        namaBulan = 'Oktober';
      break;
      case 11:
        namaBulan = 'November';
      break;
      case 12:
        namaBulan = 'Desember';
      break;
      default:
        namaBulan = 'Januari';
      break;
    }
    return namaBulan;
  }

  _onClickAction(int action) {
    switch(action){
      case 10:
        Navigator.of(context).push(_sharedAxisRoute(TransaksiPage(), SharedAxisTransitionType.horizontal));
      break;
      case 20:
        Navigator.of(context).push(_sharedAxisRoute(RiwayatTransaksiPage(), SharedAxisTransitionType.horizontal));
      break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget> [
            SliverAppBar(
              pinned: true,
              primary: true,
              forceElevated: innerBoxIsScrolled,
              expandedHeight: MediaQuery.of(context).size.height * 0.25,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: CachedNetworkImage(
                  imageUrl: fotoToko,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.25,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, downloadProgress){ 
                    return Center(
                      child: CupertinoActivityIndicator(),
                    );
                  },
                  errorWidget: (context, url, error){
                    return Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 30.0,
                      ),
                    );
                  }
                ),
                title: Text(
                  namaToko,
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.textTheme.title.color,
                    fontFamily: Theme.of(context).appBarTheme.textTheme.title.fontFamily,
                  )
                ),
                titlePadding: EdgeInsets.all(16.0),
              ),
            )
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0,),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                blurRadius: 10.0,
                                color: Theme.of(context).dividerColor,
                                offset: Offset(1.0, 1.0),
                              )
                            ]
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13.0),
                            child: CachedNetworkImage(
                              imageUrl: fotoUser,
                              width: MediaQuery.of(context).size.width * 0.12,
                              height: MediaQuery.of(context).size.width * 0.12,
                              fit: BoxFit.cover,
                              progressIndicatorBuilder: (context, url, downloadProgress){ 
                                return Center(
                                  child: CupertinoActivityIndicator(),
                                );
                              },
                              errorWidget: (context, url, error){
                                return Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 30.0,
                                  ),
                                );
                              }
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * 0.18 + 48.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cashier',
                                style: TextStyle(
                                  fontSize: Theme.of(context).textTheme.caption.fontSize,
                                  color: Theme.of(context).textTheme.caption.color,
                                ),
                              ),
                              Text(
                                namaUser,
                                style: TextStyle(
                                  fontFamily: 'Google2',
                                  fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Divider(),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      'Today overview',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.headline6.fontSize,
                        fontFamily: 'Google2',
                      ),
                    ),
                    SizedBox(
                      height: 3.0,
                    ),
                    Text(
                      '${_getToday()}, ${DateTime.now().day} ${_getNamaBulan(DateTime.now().month)} ${DateTime.now().year}',
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Material(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey[100],
                      child: ListTile(
                        onTap: (){},
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_rounded,
                              color: Theme.of(context).accentColor,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              'Transaction',
                              style: TextStyle(
                                fontFamily: 'Google'
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '7 T',
                          style: TextStyle(
                            fontFamily: 'Google2'
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Material(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.green[50],
                      child: ListTile(
                        onTap: (){},
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Theme.of(context).accentColor,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              'Income',
                              style: TextStyle(
                                fontFamily: 'Google'
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          'Rp. 725.000,-',
                          style: TextStyle(
                            fontFamily: 'Google2'
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 30.0, bottom: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All menu',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.headline6.fontSize,
                        fontFamily: 'Google2',
                      ),
                    ),
                    GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: MediaQuery.of(context).size.width * 0.025,
                      mainAxisSpacing: MediaQuery.of(context).size.height * 0.025,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: listMenu.map((menu){
                        return GestureDetector(
                          onTap: (){
                            _onClickAction(menu.action);
                          },
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.14,
                                  height: MediaQuery.of(context).size.width * 0.14,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.045),
                                    color: menu.color,
                                  ),
                                  child: Icon(
                                    menu.icon,
                                    color: Colors.white,
                                    size: 32.0,
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  menu.title,
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.caption.fontSize,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              FlatButton(onPressed: () async {
                SharedPreferences preferences = await SharedPreferences.getInstance();
                firebaseAuth.signOut().then((value){
                  preferences.clear();
                  Navigator.of(context).pushReplacement(_sharedAxisRoute(LoginPage(), SharedAxisTransitionType.horizontal));
                });
              }, child: Text('Logout'))
            ],
          ),
        ),
      ),
    );
  }

  Route _sharedAxisRoute(Widget destination, SharedAxisTransitionType type) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          child: child,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: type,
          fillColor: Theme.of(context).backgroundColor,
        );
      },
    );
  }

}