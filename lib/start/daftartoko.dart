import 'package:animations/animations.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kassa/admin/homeadmin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DaftarTokoPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return DaftarTokoState();
  }

}

class CategoryStore {
  final String id, name;
  bool check;

  CategoryStore(this.id, this.name, this.check);
}

class DaftarTokoState extends State{

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final Firestore firestore = Firestore.instance;
  final nameController =  TextEditingController();
  final categoryController = TextEditingController();
  final licenseController =  TextEditingController();
  final emailController =  TextEditingController();
  final phoneController =  TextEditingController();
  final addressController =  TextEditingController();
  final newpassController =  TextEditingController();
  final confirmpassController =  TextEditingController();
  List<CategoryStore> listCategoryStore = new List<CategoryStore>();
  int positioned = 0;
  bool buttonActive = false, obscureNewPass = true, obsecureConfirmPass = true, readOnly = false, loading = false, helperEmailError = false, helperConfirmPassError = false;
  String helperEmailErrorText, helperConfirmPassErrorText;

  @override
  void initState() {
    _getCategoryStore();
    super.initState();
  }

  _checkStore() {
    firestore.collection('users').where('noizin', isEqualTo: licenseController.text).getDocuments().then((value){
      if(value.documents.isNotEmpty){
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
            'The store already exists!',
            style: TextStyle(
              fontFamily: 'Rubik',
              color: Colors.white,
            ),
          ),
        ).show(context);
      } else {
        _saveStore();
      }
    });
  }

  _saveStore() {
    firestore.collection('users').add({
      'namatoko': nameController.text,
      'kategoritoko': categoryController.text,
      'noizin': licenseController.text,
      'email': emailController.text,
      'nomortelepon': phoneController.text,
      'alamat': addressController.text,
      'katasandi': confirmpassController.text,
      'role': 10,
    }).then((value){
      _registerAuth();
    });
  }

  _registerAuth() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    try {
      FirebaseUser user = (await firebaseAuth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: confirmpassController.text,
        )
      ).user;

      assert(user != null);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await firebaseAuth.currentUser();
      if (user.uid == currentUser.uid) {
        preferences.setString('nameUser', nameController.text);
        preferences.setString('addressUser', addressController.text);
        preferences.setString('categoryUser', categoryController.text);
        preferences.setString('licenseUser', licenseController.text);
        preferences.setString('phoneUser', phoneController.text);
        preferences.setInt('roleUser', 10);
        Navigator.of(context).pushAndRemoveUntil(_sharedAxisRoute(HomePage(), SharedAxisTransitionType.horizontal), (Route<dynamic> route) => false);
      }
    } catch (e) {
      print('Error Login: $e');
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

  _getCategoryStore() async {
    List<CategoryStore> listCategoryStoreTemp = new List<CategoryStore>();
    await firestore.collection('kategoritoko').orderBy('nama').getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) {
          CategoryStore categoryStore = new CategoryStore(f.documentID, f.data['nama'], false);
          listCategoryStoreTemp.add(categoryStore);
        });
      }
    });
    if(mounted){
      if(listCategoryStoreTemp.length > 0){
        setState(() {
          listCategoryStore = listCategoryStoreTemp;
        });
      }
    }
  }

  _enableButton(){
    if(positioned == 0){
      if(nameController.text.length > 3 && categoryController.text.length > 0 && licenseController.text.length > 10 && validateEmail(emailController.text) && phoneController.text.length > 8 && addressController.text.length > 10){
        setState(() {
          helperEmailErrorText = null;
          helperEmailError = false;
          buttonActive = true;
        });
      } else {
        setState(() {
          if(!validateEmail(emailController.text)){
            helperEmailErrorText = 'Enter your email address!';
            helperEmailError = true;
          } else {
            helperEmailErrorText = null;
            helperEmailError = false;
          }
          buttonActive = false;
        });
      }
    } else {
      if(newpassController.text.length > 5 && confirmpassController.text == newpassController.text){
        setState(() {
          helperConfirmPassErrorText = null;
          helperConfirmPassError = false;
          buttonActive = true;
        });
      } else {
        setState(() {
          if(confirmpassController.text.length < 1){
            helperConfirmPassErrorText = "Confirm your password!";
            helperConfirmPassError = true;
          } else if(confirmpassController.text != newpassController.text){
            helperConfirmPassErrorText = "Password don't match!";
            helperConfirmPassError = true;
          }
          buttonActive = false;
        });
      }
    }
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value) || value == null){
      return false;
    } else {
      return true;
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
                  'Choose Category Store',
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
                    itemCount: listCategoryStore.length,
                    itemBuilder: (context, i){
                      return Column(
                        children: [
                          ListTile(
                            onTap: (){
                              for(int j = 0; j < listCategoryStore.length; j++){
                                if(listCategoryStore[j].id != listCategoryStore[i].id){
                                  listCategoryStore[j].check = false;
                                }
                              }
                              setState(() {
                                listCategoryStore[i].check = true; 
                                categoryController.text = listCategoryStore[i].name;
                              });
                              _enableButton();
                              Navigator.pop(context);
                            },
                            leading: Icon(
                              listCategoryStore[i].check ? Icons.check_circle_outline_rounded : Icons.radio_button_off_rounded,
                              color: listCategoryStore[i].check ? Theme.of(context).accentColor : null,
                            ),
                            title: Text(
                              listCategoryStore[i].name,
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                              ),
                            ),
                          ),
                          if(i < listCategoryStore.length - 1)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget> [
            SliverAppBar(
              primary: true,
              pinned: true,
              title: Text(
                'Register Store'
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
            color: Theme.of(context).backgroundColor,
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 16.0, bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/login.png',
                                width: MediaQuery.of(context).size.width * 0.45,
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                nameController.text.length > 0 ? nameController.text : 'My First Store',
                                style: TextStyle(
                                  fontFamily: 'Google2',
                                  fontSize: Theme.of(context).textTheme.headline5.fontSize,
                                ),
                              ),
                              Text(
                                addressController.text.length > 0 ? addressController.text : '',
                                style: TextStyle(
                                  fontSize: Theme.of(context).textTheme.caption.fontSize,
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 40.0,
                        ),
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
                              transitionType: SharedAxisTransitionType.horizontal,
                              child: child,
                              fillColor: Theme.of(context).backgroundColor,);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            key: ValueKey<int>(positioned),
                            color: Theme.of(context).backgroundColor,
                            child: positioned == 0 ? _inputWidget() : _finishRegister(),
                          ),
                        ),
                      ]
                    )
                  )
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
                                  if(positioned == 0){
                                    setState(() {
                                      positioned = 1;
                                      buttonActive = false;
                                    });
                                  } else {
                                    setState(() {
                                      readOnly = true;
                                      loading = true;
                                    });
                                    _checkStore();
                                  }
                                } : (){}, 
                                child: loading ? CupertinoActivityIndicator() : Text(
                                  positioned == 0 ? 'Next' : 'Register Now'
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
    );
  }

  Widget _inputWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Name Store',
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
            hintText: 'My First Store',
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
          'Category Store',
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
            hintText: 'My Store Category',
            counter: Offstage(),
            filled: true,
            suffixIcon: listCategoryStore.length > 0 ? Icon(
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
          'License Number (SIUP/NPWP)',
        ),
        SizedBox(
          height: 8.0,
        ),
        TextFormField(
          controller: licenseController,
          readOnly: readOnly,
          onChanged: (value){
            _enableButton();
          },
          decoration: InputDecoration(
            hintText: '85677****',
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
          'Email Address',
        ),
        SizedBox(
          height: 8.0,
        ),
        TextFormField(
          controller: emailController,
          readOnly: readOnly,
          onChanged: (value){
            _enableButton();
          },
          decoration: InputDecoration(
            hintText: 'example@example.com',
            counter: Offstage(),
            helperText: helperEmailError ? helperEmailErrorText : null,
            helperStyle: TextStyle(
              color: helperEmailError ? Colors.red : null,
            ),
            filled: true,
            fillColor: helperEmailError ? Colors.red[50] : null,
            disabledBorder: UnderlineInputBorder(      
              borderSide: BorderSide(
                color: helperEmailError ? Colors.red : Theme.of(context).disabledColor,
              )   
            ),
            enabledBorder: UnderlineInputBorder(      
              borderSide: BorderSide(
                color: helperEmailError ? Colors.red : Theme.of(context).disabledColor,
              )   
            ),  
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: helperEmailError ? Colors.red : Theme.of(context).accentColor,
              )
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: helperEmailError ? Colors.red : Theme.of(context).accentColor,
              )
            )
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
          'Phone Number',
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
            hintText: '8000****',
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
          'Address',
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
            hintText: 'Jl. *****',
            counter: Offstage(),
            filled: true,
          ),
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
          ),
          maxLength: 100,
          keyboardType: TextInputType.text,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.15,
        )
      ],
    );
  }

  _finishRegister() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: TextStyle(
            fontFamily: 'Google',
          ),
        ),
        SizedBox(
          height: 8.0,
        ),
        TextFormField(
          controller: emailController,
          readOnly: true,
          onChanged: (value){
            _enableButton();
          },
          decoration: InputDecoration(
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
          'New Password',
          style: TextStyle(
            fontFamily: 'Google',
          ),
        ),
        SizedBox(
          height: 8.0,
        ),
        TextFormField(
          controller: newpassController,
          readOnly: readOnly,
          obscureText: obscureNewPass,
          onChanged: (value){
            _enableButton();
          },
          decoration: InputDecoration(
            hintText: '******',
            counter: Offstage(),
            filled: true,
            suffixIcon: IconButton(
              icon: Icon(
                obscureNewPass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              ), 
              onPressed: (){
                setState(() {
                  obscureNewPass = !obscureNewPass;
                });
              }
            )
          ),
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
          ),
          maxLength: 20,
          keyboardType: TextInputType.text,
        ),
        SizedBox(
          height: 25.0,
        ),
        Text(
          'Confirm Password',
          style: TextStyle(
            fontFamily: 'Google',
          ),
        ),
        SizedBox(
          height: 8.0,
        ),
        TextFormField(
          controller: confirmpassController,
          readOnly: readOnly,
          obscureText: obsecureConfirmPass,
          onChanged: (value){
            _enableButton();
          },
          decoration: InputDecoration(
            hintText: '******',
            counter: Offstage(),
            helperText: helperConfirmPassError ? helperConfirmPassErrorText : null,
            helperStyle: TextStyle(
              color: helperConfirmPassError ? Colors.red : null,
            ),
            filled: true,
            fillColor: helperConfirmPassError ? Colors.red[50] : null,
            disabledBorder: UnderlineInputBorder(      
              borderSide: BorderSide(
                color: helperConfirmPassError ? Colors.red : Theme.of(context).disabledColor,
              )   
            ),
            enabledBorder: UnderlineInputBorder(      
              borderSide: BorderSide(
                color: helperConfirmPassError ? Colors.red : Theme.of(context).disabledColor,
              )   
            ),  
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: helperConfirmPassError ? Colors.red : Theme.of(context).accentColor,
              )
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: helperConfirmPassError ? Colors.red : Theme.of(context).accentColor,
              )
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obsecureConfirmPass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              ), 
              onPressed: (){
                setState(() {
                  obsecureConfirmPass = !obsecureConfirmPass;
                });
              }
            )
          ),
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
          ),
          maxLength: 20,
          keyboardType: TextInputType.text,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.2
        ),
      ],
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