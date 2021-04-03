import 'dart:io';

import 'package:animations/animations.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;

class TambahProdukPage extends StatefulWidget{
  final int action;
  final String id, foto, nama, kategori, harga;

  const TambahProdukPage({Key key, @required this.action, this.id, this.foto, this.nama, this.kategori, this.harga}) : super(key: key); 
  @override
  State<StatefulWidget> createState() {
    return TambahProdukState();
  }

}

class CategoryItem {
  final String id, name;
  bool check;

  CategoryItem(this.id, this.name, this.check);
}

class TambahProdukState extends State<TambahProdukPage>{

  final Firestore firestore = Firestore.instance;
  final StorageReference fs = FirebaseStorage.instance.ref();
  final nameController =  TextEditingController();
  final categoryController = TextEditingController();
  final priceController =  TextEditingController();
  bool buttonActive = false, loading = false, readOnly = false;
  String imgProduct, idStore, namaStore;
  File _imageChoose;
  List<CategoryItem> listCategoryProduct = new List<CategoryItem>();

  @override
  void initState() {
    _getCurrentUser();
    if(widget.action == 20){
      imgProduct = widget.foto;
      nameController.text = widget.nama;
      categoryController.text = widget.kategori;
      priceController.text = widget.harga;
    }
    super.initState();
  }

  _getCurrentUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idUser');
    String nama = preferences.getString('nameUser');
    setState(() {
      idStore = id;
      namaStore = nama;
    });
    _getCategoryStore();
  }

  _getCategoryStore() async {
    List<CategoryItem> listCategoryProductTemp = new List<CategoryItem>();
    await firestore.collection('users').document(idStore).collection('kategorimenu').orderBy('nama').getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) {
          if(widget.action == 20){
            if(f.data['nama'].toString().toLowerCase() == widget.kategori.toLowerCase()){
              CategoryItem categoryStore = new CategoryItem(f.documentID, f.data['nama'], true);
              listCategoryProductTemp.add(categoryStore);
            } else {
              CategoryItem categoryStore = new CategoryItem(f.documentID, f.data['nama'], false);
              listCategoryProductTemp.add(categoryStore);
            }
          } else {
            CategoryItem categoryStore = new CategoryItem(f.documentID, f.data['nama'], false);
            listCategoryProductTemp.add(categoryStore);
          }
        });
      }
    });
    if(mounted){
      if(listCategoryProductTemp.length > 0){
        setState(() {
          listCategoryProduct = listCategoryProductTemp;
        });
      }
    }
  }

  _enableButton(){
    if(nameController.text.length > 3 && categoryController.text.length > 0 && priceController.text.length > 2){
      setState(() {
        buttonActive = true;
      });
    } else {
      setState(() {
        buttonActive = false;
      });
    }
  }

  _showAlertDialog(){
    showModal(
      context: context,
      configuration: FadeScaleTransitionConfiguration(),
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Wrap(
          children: <Widget>[
            Column(
              children: [
                SizedBox(height: 20.0,),
                Text(
                  'Choose Category Product',
                  style: TextStyle(
                    fontFamily: 'Google2',
                    fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.0,),
                Divider(height: 0.7, thickness: 0.7,),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.22,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: listCategoryProduct.length,
                    itemBuilder: (context, i){
                      return Column(
                        children: [
                          ListTile(
                            onTap: (){
                              for(int j = 0; j < listCategoryProduct.length; j++){
                                if(listCategoryProduct[j].id != listCategoryProduct[i].id){
                                  listCategoryProduct[j].check = false;
                                }
                              }
                              setState(() {
                                listCategoryProduct[i].check = true; 
                                categoryController.text = listCategoryProduct[i].name;
                              });
                              _enableButton();
                              Navigator.pop(context);
                            },
                            leading: Icon(
                              listCategoryProduct[i].check ? Icons.check_circle_outline_rounded : Icons.radio_button_off_rounded,
                              color: listCategoryProduct[i].check ? Theme.of(context).accentColor : null,
                            ),
                            title: Text(
                              listCategoryProduct[i].name,
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                              ),
                            ),
                          ),
                          if(i < listCategoryProduct.length - 1)
                          Divider(height: 0.7, thickness: 0.7, indent: 16.0, endIndent: 16.0),
                        ],
                      );
                    }
                  ),
                ),
                Divider(height: 0.7, thickness: 0.7),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: FlatButton(
                    onPressed: (){
                      Navigator.pop(context);
                    }, 
                    child: Text(
                      'Add other',
                    ),
                    textColor: Theme.of(context).buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16.0), bottomRight: Radius.circular(16.0))
                    ),
                  ),
                ),
              ],
            ),
          ],
        )
      )
    );
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

  Future _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageChoose = image;
        _compressImage(_imageChoose);
      });
    }
  }

  _compressImage(File file) async {
    final dir = await path_provider.getTemporaryDirectory();
    var name = path.basename(_imageChoose.absolute.path);
    var result = await FlutterImageCompress.compressAndGetFile(
      _imageChoose.absolute.path,
      dir.absolute.path + '/${DateTime.now()}_$name',
      quality: 60,
    );
    print('before : ' + _imageChoose.lengthSync().toString());
    print('after : ' + result.lengthSync().toString());

    setState(() {
      _imageChoose = result;
    });
  }

  _uploadImageToFirebase() async {
    StorageReference reference = fs.child('$namaStore/product/${nameController.text}');

    try {
      StorageUploadTask uploadTask = reference.putFile(_imageChoose);

      if (uploadTask.isInProgress) {
        uploadTask.events.listen((persen) async {
          double persentase = 100 *
              (persen.snapshot.bytesTransferred.toDouble() /
                  persen.snapshot.totalByteCount.toDouble());
          print(persentase);
        });

        StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
        final String url = await taskSnapshot.ref.getDownloadURL();

        setState(() {
          imgProduct = url;
          if (widget.action == 20) {
            // updateDataStaff();
          } else {
            _saveProduct();
          }
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
        readOnly = false;
      });
      Flushbar(
        reverseAnimationCurve: Curves.decelerate,
        forwardAnimationCurve: Curves.decelerate,
        flushbarPosition: FlushbarPosition.BOTTOM,
        flushbarStyle: FlushbarStyle.FLOATING,
        isDismissible: false,
        backgroundColor: Colors.red[600],
        duration: Duration(seconds: 3),
        borderRadius: 10.0,
        margin: EdgeInsets.all(16.0),
        animationDuration: Duration(milliseconds: 300),
        icon: Icon(
          Icons.info_outline_rounded,
          color: Colors.white,
        ),
        messageText: Text(
          '$e',
          style: TextStyle(
            fontFamily: 'Rubik',
            color: Colors.white,
          ),
        ),
      ).show(context);
    }
  }

  _saveProduct() async {
    await firestore.collection('produk').add({
      'foto': imgProduct,
      'nama': nameController.text,
      'kategori': categoryController.text,
      'harga': priceController.text,
      'toko': idStore,
    });
    if(mounted){
      setState(() {
        loading = false;
        readOnly = false;
      });
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget> [
            SliverAppBar(
              primary: true,
              pinned: true,
              title: Text(
                widget.action == 20 ? 'Edit Product' : 'Add New Product'
              ),
              centerTitle: true,
            )
          ];
        },
        body: GestureDetector(
          onTap: (){
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          'Product overview'
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        Row(
                          children: [
                            if(widget.action == 20 && imgProduct != null)
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
                                  imageUrl: imgProduct,
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
                            )
                            else if(widget.action == 10 && _imageChoose != null)
                            Container(
                              decoration: BoxDecoration(
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
                                child: Image.file(
                                  _imageChoose,
                                  width: MediaQuery.of(context).size.width * 0.18,
                                  height: MediaQuery.of(context).size.width * 0.18,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                            else
                            GestureDetector(
                              onTap: !loading ? (){
                                _getImage();
                              } : (){},
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.18,
                                height: MediaQuery.of(context).size.width * 0.18,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).backgroundColor,
                                  borderRadius: BorderRadius.circular(16.0),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      blurRadius: 10.0,
                                      color: Theme.of(context).dividerColor,
                                      offset: Offset(1.0, 1.0),
                                    )
                                  ],
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                    width: 0.5
                                  )
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.0),
                                  child: Center(
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 26.0,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                  )
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
                                    nameController.text.length > 0 ? nameController.text : 'Product name',
                                    style: TextStyle(
                                      fontFamily: 'Google2',
                                      fontSize: Theme.of(context).textTheme.headline6.fontSize,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    categoryController.text.length > 0 ? categoryController.text : 'Product category',
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.caption.fontSize,
                                      color: Theme.of(context).textTheme.caption.color,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Text(
                                    priceController.text.length > 0 ? _getRupiahFormat(priceController.text) : 'Price',
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        Divider(),
                        SizedBox(
                          height: 30.0,
                        ),
                        Text(
                          'Product name',
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        TextFormField(
                          controller: nameController,
                          readOnly: readOnly,
                          onChanged: (value){
                            _enableButton();
                          },
                          decoration: InputDecoration(
                            hintText: 'Input product name',
                            counter: Offstage(),
                            filled: true,
                          ),
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                          ),
                          maxLength: 50,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        Text(
                          'Product category',
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        TextFormField(
                          controller: categoryController,
                          readOnly: true,
                          onTap: (){
                            _showAlertDialog();
                          },
                          onChanged: (value){
                            _enableButton();
                          },
                          decoration: InputDecoration(
                            hintText: 'Choose product category',
                            counter: Offstage(),
                            filled: true,
                            suffixIcon: listCategoryProduct.length > 0 ? Icon(
                              Icons.more_vert_rounded
                            ) : CupertinoActivityIndicator()
                          ),
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                          ),
                          maxLength: 50,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        Text(
                          'Product price',
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        TextFormField(
                          controller: priceController,
                          readOnly: readOnly,
                          onChanged: (value){
                            _enableButton();
                          },
                          decoration: InputDecoration(
                            hintText: 'Input product price',
                            counter: Offstage(),
                            filled: true,
                          ),
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                          ),
                          maxLength: 15,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Divider(
                        thickness: 1.0,
                        height: 1.0,
                      ),
                      Container(
                        color: Theme.of(context).backgroundColor,
                        padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 16.0, bottom: 16.0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 50.0,
                              child: FlatButton(
                                onPressed: buttonActive && !loading ? (){
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                  setState(() {
                                    readOnly = true;
                                    loading = true;
                                  });
                                  _uploadImageToFirebase();
                                } : (){}, 
                                child: loading ? CupertinoActivityIndicator() : Text(
                                  widget.action == 20 ? 'Update product' : 'Save product'
                                ),
                                textColor: Colors.white,
                                color: buttonActive && !loading ? Theme.of(context).buttonColor : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ]
            )
          )
        ),
      ),
    );
  }

}