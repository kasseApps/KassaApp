import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kassa/custom/appbar.dart';
import 'package:kassa/start/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilTokoPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ProfilTokoState();
  }

}

class ProfilTokoState extends State{

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String idStore, fotoStore, namaStore, emailStore, kategoriStore, noizinStore, alamatStore, teleponStore;
  
  @override
  void initState() {
    _getCurrentUser();
    super.initState();
  }

  _getCurrentUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idUser');
    String foto = preferences.getString('fotoUser');
    String nama = preferences.getString('nameUser');
    String email = preferences.getString('emailUser');
    String kategori = preferences.getString('categoryUser');
    String noizin = preferences.getString('licenseUser');
    String alamat = preferences.getString('addressUser');
    String telepon = preferences.getString('phoneUser');
    setState(() {
      idStore = id;
      if(foto == null){
        fotoStore = 'https://firebasestorage.googleapis.com/v0/b/kassaapps-d7ece.appspot.com/o/store.jpeg?alt=media&token=e53fbe4f-029c-4972-8786-6afbae5a7c8e';
      } else {
        fotoStore = foto;
      }
      namaStore = nama;
      emailStore = email;
      kategoriStore = kategori;
      noizinStore = noizin;
      alamatStore = alamat;
      teleponStore = telepon;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget> [
            SliverAppBar(
              pinned: true,
              primary: true,
              forceElevated: innerBoxIsScrolled,
              title: AppBarCollaps(
                child: Text(
                  namaStore,
                )
              ),
              expandedHeight: MediaQuery.of(context).size.height * 0.25,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: CachedNetworkImage(
                  imageUrl: fotoStore,
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
              ),
              centerTitle: true,
            )
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaStore,
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.headline5.fontSize,
                        fontFamily: 'Google2',
                      ),
                    ),
                    Text(
                      alamatStore
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 13.0, right: 13.0, top: 4.0, bottom: 4.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).accentColor,
                        borderRadius: BorderRadius.circular(15.0)
                      ),
                      child: Text(
                        kategoriStore,
                        style: TextStyle(
                          color: Colors.grey[100]
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Divider(),
                  ],
                ),
              ),
              ListTile(
                onTap: (){},
                leading: Icon(
                  Icons.payments_rounded,
                  color: Colors.red[600],
                  size: 24.0,
                ),
                title: Text(
                  'Manage payment method',
                  style: TextStyle(
                    fontFamily: 'Google'
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded
                ),
              ),
              Divider(
                indent: 16.0,
                endIndent: 16.0,
              ),
              ListTile(
                onTap: (){},
                leading: Icon(
                  Icons.device_unknown_rounded,
                  color: Colors.indigo[600],
                  size: 24.0,
                ),
                title: Text(
                  'Manage devices store',
                  style: TextStyle(
                    fontFamily: 'Google'
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded
                ),
              ),
              Divider(
                indent: 16.0,
                endIndent: 16.0,
              ),
              ListTile(
                onTap: (){},
                leading: Icon(
                  Icons.print_rounded,
                  color: Colors.blue[600],
                  size: 24.0,
                ),
                title: Text(
                  'Manage payment receipts style',
                  style: TextStyle(
                    fontFamily: 'Google'
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded
                ),
              ),
              Divider(
                indent: 16.0,
                endIndent: 16.0,
              ),
              ListTile(
                onTap: (){
                  firebaseAuth.signOut().then((value){
                    Navigator.of(context).pushReplacement(_sharedAxisRoute(LoginPage(), SharedAxisTransitionType.horizontal));
                  });
                },
                leading: Icon(
                  Icons.logout,
                  color: Colors.deepOrange[600],
                  size: 24.0,
                ),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    fontFamily: 'Google'
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded
                ),
              )
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