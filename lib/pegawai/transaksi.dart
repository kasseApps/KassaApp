import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransaksiPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return TransaksiState();
  }

}

class CategoryProduct {
  final String id, nama;
  List<ProductItem> listProduct;

  CategoryProduct(this.id, this.nama, this.listProduct);
}

class ProductItem {
  final String id, foto, nama, kategori, harga;
  int pesan, total;

  ProductItem(this.id, this.foto, this.nama, this.kategori, this.harga, this.pesan, this.total);
}

class TransaksiState extends State with SingleTickerProviderStateMixin{

  final Firestore firestore = Firestore.instance;
  TabController _tabcontroller;
  List<CategoryProduct> listCategoryProduct = new List<CategoryProduct>();
  List<ProductItem> listProduct = new List<ProductItem>();
  String idToko, idUser;
  int itemAdd = 0, totalAdd = 0;
  
  @override
  void initState() {
    _getCurrentUsers();
    super.initState();
  }

  _getCurrentUsers() async {
    List<CategoryProduct> listCategoryProductTemp = new List<CategoryProduct>();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idtoko = preferences.getString('idToko');
    String iduser = preferences.getString('idUser');
    List<dynamic> listTemp = jsonDecode(preferences.getString('kategoriproduk'));
    if(listTemp.length > 0){
      for(int i = 0; i < listTemp.length; i++){
        CategoryProduct categoryProduct = new CategoryProduct(listTemp[i]['id'], listTemp[i]['nama'], null);
        listCategoryProductTemp.add(categoryProduct);
      }
    }
    setState(() {
      idToko = idtoko;
      idUser = iduser;
      listCategoryProduct = listCategoryProductTemp;
    });
    _tabcontroller = new TabController(vsync: this, length: listCategoryProduct.length);
    _getAllProduct();
  }

  _getAllProduct() async {
    List<ProductItem> listProductTemp = new List<ProductItem>();
    await firestore.collection('produk').where('toko', isEqualTo: idToko).getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) {
          ProductItem productItem = new ProductItem(f.documentID, f.data['foto'], f.data['nama'], f.data['kategori'], f.data['harga'], 0, 0);
          listProductTemp.add(productItem);
        });
      }
    });
    if(mounted){
      if(listProductTemp.length > 0){
        setState(() {
          listProduct = listProductTemp;
        });
        _fillteringMenu();
      }
    }
  }

  _fillteringMenu() {
    for(int i = 0; i < listCategoryProduct.length; i++){
      List<ProductItem> listProductTemp = new List<ProductItem>();
      for(int j = 0; j < listProduct.length; j++){
        if(listCategoryProduct[i].nama.toLowerCase() == listProduct[j].kategori.toLowerCase()){
          listProductTemp.add(listProduct[j]);
        }
        if(j == listProduct.length - 1){
          setState(() {
            listProductTemp.sort((a,b) => a.nama.compareTo(b.nama));
            listCategoryProduct[i].listProduct = listProductTemp;
          });
        }
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget> [
            SliverAppBar(
              pinned: true,
              primary: true,
              floating: true,
              title: Text(
                'Transaction'
              ),
              centerTitle: true,
              bottom: listCategoryProduct.length > 0 ? TabBar(
                isScrollable: listCategoryProduct.length > 2 ? true : false,
                labelPadding: EdgeInsets.only(left: 25.0, right: 25.0),
                controller: _tabcontroller,
                tabs: [
                  for(int i = 0; i < listCategoryProduct.length; i++)
                  Tab(
                    text: listCategoryProduct[i].nama,
                  ),
                ]
              ) : null,
            )
          ];
        },
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              if(listCategoryProduct.length > 0)
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: TabBarView(
                  controller: _tabcontroller,
                  children: [
                    for(int i = 0; i < listCategoryProduct.length; i++)
                    _menuView(i),
                  ]
                ),
              ),
              AnimatedPositioned(
                bottom: itemAdd > 0 ? 16.0 : -65.0,
                left: 16.0,
                right: 16.0,
                duration: Duration(
                  milliseconds: 400
                ),
                curve: Curves.fastOutSlowIn,
                child: Container(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 14.0, bottom: 14.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: Theme.of(context).accentColor,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_basket_rounded,
                        size: 26.0,
                        color: Colors.grey[100],
                      ),
                      SizedBox(
                        width: 16.0,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Text(
                          '$itemAdd Items',
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.subtitle1.fontSize - 1.0,
                            color: Colors.grey[100],
                          ),
                        ),
                      ),
                      Spacer(),
                      Text(
                        '${_getRupiahFormat(totalAdd.toString())}',
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                          color: Colors.grey[100],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuView(int index) {
    return listCategoryProduct[index].listProduct != null ? SingleChildScrollView(
      child: Column(
        children: [
          for(int i = 0; i < listCategoryProduct[index].listProduct.length; i++)
          InkWell(
            onTap: () {
              setState(() {
                itemAdd = itemAdd + 1;
                totalAdd = totalAdd + int.parse(listCategoryProduct[index].listProduct[i].harga);
                listCategoryProduct[index].listProduct[i].pesan = listCategoryProduct[index].listProduct[i].pesan + 1;
              });
            },
            onLongPress: (){
              setState(() {
                itemAdd = itemAdd - listCategoryProduct[index].listProduct[i].pesan;
                totalAdd = totalAdd - (int.parse(listCategoryProduct[index].listProduct[i].harga) * listCategoryProduct[index].listProduct[i].pesan);
                listCategoryProduct[index].listProduct[i].pesan = 0;
              });
            },
            child: Container(
              margin: EdgeInsets.only(left: 16.0, right: 16.0,),
              child: Column(
                children: [
                  SizedBox(
                    height: 5.0,
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
                            imageUrl: listCategoryProduct[index].listProduct[i].foto,
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
                        width: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * 0.18 + 93.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listCategoryProduct[index].listProduct[i].nama,
                              style: TextStyle(
                                fontFamily: 'Google2',
                                fontSize: Theme.of(context).textTheme.headline6.fontSize - 2.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              listCategoryProduct[index].listProduct[i].kategori,
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.caption.fontSize,
                                color: Theme.of(context).textTheme.caption.color,
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              '${_getRupiahFormat(listCategoryProduct[index].listProduct[i].harga)}',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 45.0,
                        child: Column(
                          children: [
                            InkWell(
                              onTap: (){
                                setState(() {
                                  itemAdd = itemAdd + 1;
                                  totalAdd = totalAdd + int.parse(listCategoryProduct[index].listProduct[i].harga);
                                  listCategoryProduct[index].listProduct[i].pesan = listCategoryProduct[index].listProduct[i].pesan + 1;
                                });
                              },
                              borderRadius: BorderRadius.circular(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Icon(
                                  Icons.keyboard_arrow_up_rounded,
                                  size: 26.0,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            Text(
                              '${listCategoryProduct[index].listProduct[i].pesan}',
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                              ),
                            ),
                            InkWell(
                              onTap: listCategoryProduct[index].listProduct[i].pesan == 0 ? (){} : (){
                                setState(() {
                                  itemAdd = itemAdd - 1;
                                  totalAdd = totalAdd - int.parse(listCategoryProduct[index].listProduct[i].harga);
                                  listCategoryProduct[index].listProduct[i].pesan = listCategoryProduct[index].listProduct[i].pesan - 1;
                                });
                              },
                              borderRadius: BorderRadius.circular(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 26.0,
                                  color: listCategoryProduct[index].listProduct[i].pesan == 0 ? Theme.of(context).disabledColor : Colors.red,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    indent: MediaQuery.of(context).size.width * 0.18 + 16.0,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
          )
        ],
      ),
    ) : Container(
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
    );
  }

}