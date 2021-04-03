import 'package:animations/animations.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kassa/admin/tambahpegawai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListPegawaiPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ListPegawaiState();
  }

}

class EmployeeItem {
  final String id, foto, nama, email, phone, address;

  EmployeeItem(this.id, this.foto, this.nama, this.email, this.phone, this.address);
}

class ListPegawaiState extends State{

  final Firestore firestore = Firestore.instance;
  List<EmployeeItem> listEmployee = new List<EmployeeItem>();
  String idStore;
  bool isEmpty = false;

  @override
  void initState() {
    _getCurrentUser();
    super.initState();
  }

  _getCurrentUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idUser');
    setState(() {
      idStore = id;
    });
    _getAllEmployee();
  }

  _getAllEmployee() async {
    List<EmployeeItem> listEmployeeTemp = new List<EmployeeItem>();
    await firestore.collection('users').where('toko', isEqualTo: idStore).getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) {
          EmployeeItem product = new EmployeeItem(f.documentID, f.data['foto'], f.data['nama'], f.data['email'], f.data['telepon'], f.data['alamat']);
          listEmployeeTemp.add(product);
        });
      }
    });
    if(mounted){
      if(listEmployeeTemp.length > 0){
        listEmployeeTemp.sort((a,b) => a.nama.compareTo(b.nama));
        setState(() {
          listEmployee = listEmployeeTemp;
        });
      } else {
        setState(() {
          isEmpty = true;
        });
      }
    }
  }

  String splitPhoneNumber(String number) {
    String splitNumber = '';
    for(int i = 0; i < number.length; i++){
      if(i == 2 || i == 6){
        splitNumber = splitNumber + number[i] + '-';
      } else {
        splitNumber = splitNumber + number[i];
      }
    }
    return splitNumber;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add_rounded,
          size: 28.0,
        ),
        onPressed: () async {
          final result = await Navigator.of(context).push(_sharedAxisRoute(TambahPegawaiPage(action: 10,), SharedAxisTransitionType.horizontal));
          if(result != null){
            if(result){
              _getAllEmployee();
              Flushbar(
                reverseAnimationCurve: Curves.decelerate,
                forwardAnimationCurve: Curves.decelerate,
                flushbarPosition: FlushbarPosition.BOTTOM,
                flushbarStyle: FlushbarStyle.FLOATING,
                isDismissible: false,
                backgroundColor: Colors.green[600],
                duration: Duration(seconds: 3),
                borderRadius: 10.0,
                margin: EdgeInsets.all(16.0),
                animationDuration: Duration(milliseconds: 300),
                icon: Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.white,
                ),
                messageText: Text(
                  'Success add new employee',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    color: Colors.white,
                  ),
                ),
              ).show(context);
            }
          }
        },
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget> [
            SliverAppBar(
              primary: true,
              pinned: true,
              title: Text(
                'Employees'
              ),
              centerTitle: true,
            )
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            children: [
              if(listEmployee.length > 0)
              for(int i = 0; i < listEmployee.length; i++)
              InkWell(
                onTap: () async {
                  final result = await Navigator.of(context).push(_sharedAxisRoute(TambahPegawaiPage(action: 20, id: listEmployee[i].id, foto: listEmployee[i].foto, nama: listEmployee[i].nama, email: listEmployee[i].email, phone: listEmployee[i].phone, alamat: listEmployee[i].address,), SharedAxisTransitionType.horizontal));
                },
                child: Container(
                  margin: EdgeInsets.only(left: 16.0, right: 16.0,),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 16.0,
                      ),
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
                              borderRadius: BorderRadius.circular(16.0),
                              child: CachedNetworkImage(
                                imageUrl: listEmployee[i].foto,
                                width: MediaQuery.of(context).size.width * 0.18,
                                height: MediaQuery.of(context).size.width * 0.18,
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
                                  listEmployee[i].nama,
                                  style: TextStyle(
                                    fontFamily: 'Google2',
                                    fontSize: Theme.of(context).textTheme.headline6.fontSize - 2.0,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '+62-${splitPhoneNumber(listEmployee[i].phone)}',
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.caption.fontSize,
                                    color: Theme.of(context).textTheme.caption.color,
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  listEmployee[i].email,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      Divider(
                        height: 0.5,
                        thickness: 0.5,
                        indent: MediaQuery.of(context).size.width * 0.18 + 16.0,
                      ),
                    ],
                  ),
                ),
              )
              else if(isEmpty)
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.8,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_add_rounded,
                        size: 46.0,
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        'Employee not found!',
                        style: Theme.of(context).textTheme.caption,
                      )
                    ],
                  ),
                )
              )
              else
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.8,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoActivityIndicator(),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        'Loading...',
                        style: Theme.of(context).textTheme.caption,
                      )
                    ],
                  ),
                )
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
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