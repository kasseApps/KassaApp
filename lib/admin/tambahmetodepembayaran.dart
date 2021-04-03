import 'package:animations/animations.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TambahMetodePembayaranPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return TambahMetodePembayaranState();
  }

}

class PaymentItem {
  final String id, name;
  bool status;

  PaymentItem(this.id, this.name, this.status);
}

class TambahMetodePembayaranState extends State{

  final Firestore firestore = Firestore.instance;
  final namaController = TextEditingController();
  List<PaymentItem> listPayMethod = new List<PaymentItem>();
  String idStore, namaStore;
  bool isEmpty = false, readOnly = false, usePayment = true, buttonActive = true, loading = false;
  int positioned = 0;
  
  @override
  void initState() {
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
    _getPaymentMethodeStore();
  }

  _getPaymentMethodeStore() async {
    List<PaymentItem> listPayMethodTemp = new List<PaymentItem>();
    await firestore.collection('users').document(idStore).collection('metodebayar').orderBy('nama').getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) {
          PaymentItem paymentMethod = new PaymentItem(f.documentID, f.data['nama'], f.data['status']);
          listPayMethodTemp.add(paymentMethod);
        });
      }
    });
    if(mounted){
      if(listPayMethodTemp.length > 0){
        setState(() {
          listPayMethod = listPayMethodTemp;
        });
      } else {
        setState(() {
          isEmpty = true;
        });
      }
    }
  }

  _enableButton(){
    if(namaController.text.length > 2){
      setState(() {
        buttonActive = true;
      });
    } else {
      setState(() {
        buttonActive = false;
      });
    }
  }

  _checkPaymentMethod() async {
    bool already = false;
    await firestore.collection('users').document(idStore).collection('metodebayar').getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) {
          if(f.data['nama'].toString().toLowerCase() == namaController.text.toLowerCase()){
            already = true;
          }
        });
      }
    });
    if(mounted){
      if(!already){
        _savePaymentMethod();
      } else {
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
            'Payment method already exists!',
            style: TextStyle(
              fontFamily: 'Rubik',
              color: Colors.white,
            ),
          ),
        ).show(context);
      }
    }
  }

  _savePaymentMethod() async {
    await firestore.collection('users').document(idStore).collection('metodebayar').add({
      'nama': namaController.text,
      'status': usePayment,
    });
    if(mounted){
      setState(() {
        loading = false;
        readOnly = false;
        positioned = 0;
        namaController.text = '';
      });
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
          'Success add new payment method',
          style: TextStyle(
            fontFamily: 'Rubik',
            color: Colors.white,
          ),
        ),
      ).show(context);
      _getPaymentMethodeStore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget> [
              SliverAppBar(
                pinned: true,
                primary: true,
                title: Text(
                  'Payment Method'
                ),
                centerTitle: true,
              )
            ];
          },
          body: Container(
            child: Stack(
              children: [
                PageTransitionSwitcher(
                  duration: Duration(
                    milliseconds: 400,
                  ),
                  transitionBuilder: (
                    Widget child,
                    Animation<double> primaryAnimation,
                    Animation<double> secondaryAnimation, 
                  ){
                    return SharedAxisTransition(
                      animation: primaryAnimation, 
                      secondaryAnimation: secondaryAnimation, 
                      transitionType: SharedAxisTransitionType.scaled,
                      child: child,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,);
                  },
                  child: GestureDetector(
                    onTap: positioned == 1 ? (){
                      FocusScope.of(context).requestFocus(new FocusNode());
                    } : (){},
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      key: ValueKey<int>(positioned),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: positioned == 0 ? _allPaymentMethod() : _addPaymentMethod(),
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
                                  if(positioned == 0){
                                    setState(() {
                                      positioned = 1;
                                      buttonActive = false;
                                    });
                                  } else {
                                    FocusScope.of(context).requestFocus(new FocusNode());
                                    setState(() {
                                      loading = true;
                                      readOnly = true;
                                    });
                                    _checkPaymentMethod();
                                  }
                                } : (){}, 
                                child: loading ? CupertinoActivityIndicator() :  Text(
                                  positioned == 0 ? 'Add new payment method' : 'Save payment method'
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
              ],
            ),
          ),
        ),
      ),
      onWillPop: positioned == 1 ? (){
        setState(() {
          positioned = 0;
          buttonActive = true;
        });
      } : null,
    );
  }

  Widget _allPaymentMethod(){
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(listPayMethod.length > 0)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0,),
            child: Text(
              'Available payment method',
              style: TextStyle(
                fontFamily: 'Google2',
                fontSize: Theme.of(context).textTheme.headline6.fontSize,
              ),
            ),
          ),
          if(listPayMethod.length > 0)
          Container(
            margin: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 0.5
              )
            ),
            child: Column(
              children: [
                for(int i = 0; i < listPayMethod.length; i++)
                Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: listPayMethod.length == 1 ? BorderRadius.circular(10.0) : i == 0 ? BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)) : i == listPayMethod.length - 1 ? BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)) : BorderRadius.zero,
                        ),
                        onTap: (){
                          setState(() {
                            listPayMethod[i].status = !listPayMethod[i].status;
                          });
                        },
                        leading: Icon(
                          Icons.payment_rounded,
                          size: 24.0,
                        ),
                        title: Text(
                          listPayMethod[i].name,
                          style: TextStyle(
                            fontFamily: 'Google2'
                          ),
                        ),
                        trailing: Switch(
                          value: listPayMethod[i].status, 
                          onChanged: (value){
                            setState(() {
                              listPayMethod[i].status = value;
                            });
                          }
                        ),
                      ),
                    ),
                    if(i != listPayMethod.length - 1)
                    Divider(
                      height: 0.5,
                      thickness: 0.5,
                    )
                  ],
                )
              ],
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
                    Icons.payments_rounded,
                    size: 46.0,
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Payment method not found!',
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
    );
  }

  Widget _addPaymentMethod(){
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0,),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.18,
              height: MediaQuery.of(context).size.width * 0.18,
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 0.5
                )
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Center(
                  child: Icon(
                    Icons.payments_rounded,
                    size: 45.0,
                    color: Theme.of(context).accentColor,
                  ),
                )
              ),
            ),
            SizedBox(
              height: 16.0,
            ),
            Text(
              'Add new payment method',
              style: TextStyle(
                fontFamily: 'Google2',
                fontSize: Theme.of(context).textTheme.headline6.fontSize,
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Text(
              'Payment method name',
            ),
            SizedBox(
              height: 8.0,
            ),
            TextFormField(
              controller: namaController,
              readOnly: readOnly,
              onChanged: (value){
                _enableButton();
              },
              decoration: InputDecoration(
                hintText: 'Input payment method name',
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
              height: 10.0,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: !loading ? (){
                setState(() {
                  usePayment = !usePayment;
                });
              } : (){},
              title: Text(
                'Use this payment method for transactions',
                style: TextStyle(
                  fontFamily: 'Google2'
                ),
              ),
              subtitle: Text(
                'This payment method can be used by customers when making payment transactions'
              ),
              isThreeLine: true,
              trailing: Switch(
                value: usePayment, 
                onChanged: !loading ? (value){
                  setState(() {
                    usePayment = value;
                  });
                } : (value){},
              ),
            )
          ],
        ),
      ),
    );
  }

}