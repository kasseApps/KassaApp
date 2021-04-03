import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kassa/admin/laporan.dart';
import 'package:kassa/admin/listpegawai.dart';
import 'package:kassa/admin/listproduk.dart';
import 'package:kassa/admin/profiletoko.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }

}

class MenuAdmin {
  final IconData icon;
  final String title;
  final int action;
  final Color color;

  MenuAdmin(this.icon, this.title, this.action, this.color);
}

class HomeState extends State{

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  List<MenuAdmin> listMenu = new List<MenuAdmin>();
  String idToko, fotoToko, namaToko, alamatToko, kategoriToko, noizinToko, teleponToko;

  MenuAdmin menu1 = new MenuAdmin(Icons.shopping_basket_rounded, 'Products', 10, Colors.blue);
  MenuAdmin menu2 = new MenuAdmin(Icons.assignment_ind_rounded,'Employees', 20, Colors.orange);
  MenuAdmin menu3 = new MenuAdmin(Icons.assignment_rounded, 'Reports', 30, Colors.blueGrey);
  MenuAdmin menu4 = new MenuAdmin(Icons.store_rounded, 'My Store', 40, Colors.green);

  @override
  void initState() {
    listMenu.add(menu1);
    listMenu.add(menu2);
    listMenu.add(menu3);
    listMenu.add(menu4);
    _getCurrentUsers();
    super.initState();
  }

  _getCurrentUsers() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idUser');
    String foto = preferences.getString('fotoUser');
    String namatoko = preferences.getString('nameUser');
    String alamattoko = preferences.getString('addressUser');
    String kategoritoko = preferences.getString('categoryUser');
    String noizintoko = preferences.getString('licenseUser');
    String telepontoko = preferences.getString('phoneUser');
    setState(() {
      idToko = id;
      if(foto == null){
        fotoToko = 'https://firebasestorage.googleapis.com/v0/b/kassaapps-d7ece.appspot.com/o/store.jpeg?alt=media&token=e53fbe4f-029c-4972-8786-6afbae5a7c8e';
      } else {
        fotoToko = foto;
      }
      namaToko = namatoko;
      alamatToko = alamattoko;
      kategoriToko = kategoritoko;
      noizinToko = noizintoko;
      teleponToko = telepontoko;
    });
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
        Navigator.of(context).push(_sharedAxisRoute(ListProdukPage(), SharedAxisTransitionType.horizontal));
      break;
      case 20:
        Navigator.of(context).push(_sharedAxisRoute(ListPegawaiPage(), SharedAxisTransitionType.horizontal));
      break;
      case 30:
        Navigator.of(context).push(_sharedAxisRoute(LaporanPage(), SharedAxisTransitionType.horizontal));
      break;
      case 40:
        Navigator.of(context).push(_sharedAxisRoute(ProfilTokoPage(), SharedAxisTransitionType.horizontal));
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
              primary: true,
              pinned: true,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 25.0,),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    )
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 30.0, bottom: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage store',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.headline6.fontSize,
                        fontFamily: 'Google2',
                      ),
                    ),
                    GridView.count(
                      crossAxisCount: 4,
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