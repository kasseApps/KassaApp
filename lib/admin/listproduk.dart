import 'package:animations/animations.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kassa/admin/tambahproduk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListProdukPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ListProdukState();
  }

}

class ProductItem {
  final String id, foto, nama, kategori, harga;

  ProductItem(this.id, this.foto, this.nama, this.kategori, this.harga);
}

class ListProdukState extends State{

  final Firestore firestore = Firestore.instance;
  List<ProductItem> listProduct = new List<ProductItem>();
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
    _getAllProduct();
  }

  _getAllProduct() async {
    List<ProductItem> listProductTemp = new List<ProductItem>();
    await firestore.collection('produk').where('toko', isEqualTo: idStore).getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) {
          ProductItem product = new ProductItem(f.documentID, f.data['foto'], f.data['nama'], f.data['kategori'], f.data['harga']);
          listProductTemp.add(product);
        });
      }
    });
    if(mounted){
      if(listProductTemp.length > 0){
        listProductTemp.sort((a,b) => a.nama.compareTo(b.nama));
        setState(() {
          listProduct = listProductTemp;
        });
      } else {
        setState(() {
          isEmpty = true;
        });
      }
    }
  }

  String _getRupiahFormat(String number){
    String rupiah = ',-';
    int count = 0;
    for(int i = (number.length - 1); i >= 0; i--){
      count++;
      if(count == 3 && i != 0){
        rupiah = '.' + number[i] + rupiah;
        count = 0;
      } else {
        rupiah = number[i] + rupiah;
      }
    }
    rupiah = 'Rp.' + rupiah;
    return rupiah;
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
          final result = await Navigator.of(context).push(_sharedAxisRoute(TambahProdukPage(action: 10,), SharedAxisTransitionType.horizontal));
          if(result != null){
            if(result){
              _getAllProduct();
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
                  'Success add new product',
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
                'All Products'
              ),
              centerTitle: true,
            )
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            children: [
              if(listProduct.length > 0)
              for(int i = 0; i < listProduct.length; i++)
              InkWell(
                onTap: () async {
                  final result = await Navigator.of(context).push(_sharedAxisRoute(TambahProdukPage(action: 20, id: listProduct[i].id, foto: listProduct[i].foto, nama: listProduct[i].nama, kategori: listProduct[i].kategori, harga: listProduct[i].harga,), SharedAxisTransitionType.horizontal));
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
                                imageUrl: listProduct[i].foto,
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
                                  listProduct[i].nama,
                                  style: TextStyle(
                                    fontFamily: 'Google2',
                                    fontSize: Theme.of(context).textTheme.headline6.fontSize - 2.0,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  listProduct[i].kategori,
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.caption.fontSize,
                                    color: Theme.of(context).textTheme.caption.color,
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  '${_getRupiahFormat(listProduct[i].harga)}',
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
                        Icons.shopping_bag_outlined,
                        size: 46.0,
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        'Product not found!',
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