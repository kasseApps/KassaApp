import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;

class TambahPegawaiPage extends StatefulWidget{

  final int action;
  final String id, foto, nama, email, phone, alamat;

  const TambahPegawaiPage({Key key, @required this.action, this.id, this.foto, this.nama, this.email, this.phone, this.alamat}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TambahPegawaiState();
  }

}

class TambahPegawaiState extends State<TambahPegawaiPage> {

  final Firestore firestore = Firestore.instance;
  final StorageReference fs = FirebaseStorage.instance.ref();
  final nameController =  TextEditingController();
  final emailController = TextEditingController();
  final phoneController =  TextEditingController();
  final addressController =  TextEditingController();
  bool buttonActive = false, loading = false, readOnly = false;
  String imgEmployee, idStore, namaStore;
  File _imageChoose;
  
  @override
  void initState() {
    if(widget.action == 20){
      imgEmployee = widget.foto;
      nameController.text = widget.nama;
      emailController.text = widget.email;
      phoneController.text = widget.phone;
      addressController.text = widget.alamat;
    }
    _getCurrentUser();
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
  }

  _enableButton(){
    if(nameController.text.length > 2 && emailController.text.length > 10 && phoneController.text.length > 8 && addressController.text.length > 10){
      setState(() {
        buttonActive = true;
      });
    } else {
      setState(() {
        buttonActive = false;
      });
    }
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

  _checkUsers(int action){
    firestore.collection('users').where('email', isEqualTo: emailController.text).getDocuments().then((value){
      if(value.documents.isEmpty){
        if(action == 10){
          _uploadImageToFirebase();
        } else {
          _saveEmployee(20);
        }
      } else {
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
            'The employee already exists!',
            style: TextStyle(
              fontFamily: 'Rubik',
              color: Colors.white,
            ),
          ),
        ).show(context);
      }
    });
  }

  _uploadImageToFirebase() async {
    StorageReference reference = fs.child('$namaStore/employee/${nameController.text}');

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
          imgEmployee = url;
          if (widget.action == 20) {
            // updateDataStaff();
          } else {
            _saveEmployee(10);
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

  _saveEmployee(int action) async {
    String password = randomAlphaNumeric(6);
    await firestore.collection('users').add({
      'foto': action == 10 ? imgEmployee : '-',
      'nama': nameController.text,
      'email': emailController.text,
      'telepon': phoneController.text,
      'alamat': addressController.text,
      'role': 20,
      'password': password,
      'setup': false,
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
                widget.action == 20 ? 'Edit Employee' : 'Add Employee'
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
                          'Employee overview'
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        Row(
                          children: [
                            if(widget.action == 20 && imgEmployee != null)
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
                                  imageUrl: imgEmployee,
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
                                    nameController.text.length > 0 ? nameController.text : 'Employee name',
                                    style: TextStyle(
                                      fontFamily: 'Google2',
                                      fontSize: Theme.of(context).textTheme.headline6.fontSize,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    phoneController.text.length > 0 ? '+62-${splitPhoneNumber(phoneController.text)}' : 'Employee phone number',
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.caption.fontSize,
                                      color: Theme.of(context).textTheme.caption.color,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Text(
                                    emailController.text.length > 0 ? emailController.text : 'Employee email address',
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
                          'Employee name',
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
                            hintText: 'Input employee name',
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
                          'Employee email address',
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        TextFormField(
                          controller: emailController,
                          readOnly: readOnly,
                          onTap: (){
                            // _showAlertDialog();
                          },
                          onChanged: (value){
                            _enableButton();
                          },
                          decoration: InputDecoration(
                            hintText: 'Input email address',
                            counter: Offstage(),
                            filled: true,
                          ),
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                          ),
                          maxLength: 50,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        Text(
                          'Employee phone number',
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        TextFormField(
                          controller: phoneController,
                          readOnly: readOnly,
                          onChanged: (value){
                            _enableButton();
                          },
                          decoration: InputDecoration(
                            hintText: 'Input phone number',
                            counter: Offstage(),
                            filled: true,
                          ),
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                          ),
                          maxLength: 12,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        Text(
                          'Employee home address',
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        TextFormField(
                          controller: addressController,
                          readOnly: readOnly,
                          onChanged: (value){
                            _enableButton();
                          },
                          decoration: InputDecoration(
                            hintText: 'Input home address',
                            counter: Offstage(),
                            filled: true,
                          ),
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                          ),
                          maxLength: 100,
                          keyboardType: TextInputType.text,
                          maxLines: null,
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
                                  if(widget.action == 10 && _imageChoose != null){
                                    _checkUsers(10);
                                  } else {
                                    _checkUsers(20);
                                  }
                                } : (){}, 
                                child: loading ? CupertinoActivityIndicator() : Text(
                                  widget.action == 20 ? 'Update employee' : 'Save employee'
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