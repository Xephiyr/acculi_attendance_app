import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:acculi_attendance_app/sign_in.dart';
import 'package:acculi_attendance_app/the_user.dart' as global;

TextEditingController numberController;
TextEditingController smsController;
String _verificationId;
final FirebaseAuth _auth = FirebaseAuth.instance;
var database = FirebaseFirestore.instance;

class PhoneAuth extends StatefulWidget {
  @override
  PhoneAuthState createState() => PhoneAuthState();
}

bool enabledb = false;

class PhoneAuthState extends State<PhoneAuth> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    numberController = TextEditingController();
    numberController.text = '+91';
    smsController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    numberController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData deviceInfo = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Lyfas On-Ground Support'),
      ),
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
        child: Container(
          width: deviceInfo.size.width,
          height: deviceInfo.size.height,
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    controller: numberController,
                    decoration: InputDecoration(
                      hintText: 'Enter your PhoneNumber ',
                      labelText: 'Phone number',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (phone) {
                      if (phone.isEmpty) {
                        return 'Number cannot be empty';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 200),
              Align(
                alignment: Alignment.bottomCenter,
                child: OutlineButton(
                  //returns outline button
                  splashColor: Colors.grey,
                  onPressed: () async {
                    String number, result;
                    number = numberController.text;
                    verifyPhoneNumber(context, number);
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  highlightElevation: 0,
                  borderSide: BorderSide(color: Colors.grey),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Text(
                      'Verify Phone Number',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    controller: smsController,
                    decoration: InputDecoration(
                      hintText: 'Enter the sms code ',
                      labelText: 'Sms Code',
                      prefixIcon: Icon(Icons.mail),
                    ),
                    validator: (phone) {
                      if (phone.isEmpty) {
                        return 'Number cannot be empty';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 200),
              Align(
                alignment: Alignment.bottomCenter,
                child: OutlineButton(
                  //returns outline button
                  splashColor: Colors.grey,
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      String sms, number;
                      sms = smsController.text;
                      number = numberController.text;
                      String check;
                      signInWithPhoneNumber(context, number, sms);

                      Navigator.pushReplacementNamed(context, '/user');
                    }
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  highlightElevation: 0,
                  borderSide: BorderSide(color: Colors.grey),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void verifyPhoneNumber(BuildContext context, String number) async {
  await Firebase.initializeApp();
  bool us = await getBoolFromSharedPref();
  if (us == true) {
    global.clearSessionData();
  }
  PhoneVerificationCompleted verificationCompleted =
      (PhoneAuthCredential phoneAuthCredential) async {
    User currentuser = _auth.currentUser;
    if (currentuser != null) {
      try {
        currentuser.linkWithCredential(phoneAuthCredential);
        //update emp table
        final QuerySnapshot query =
            await database.collection('emp').where('Email', isEqualTo: currentuser.email).get();
        if (query.size != 0) {
          var snapshot = query.docs[0];
          global.globalSessionData.name = snapshot.data()['Name'];
          global.globalSessionData.email = snapshot.data()['Email'];
          global.globalSessionData.nfcID = snapshot.data()['NfcID'];
          global.globalSessionData.phoneNo = number;
          global.globalSessionData.myId = snapshot.id;
          if (snapshot.data()['phone'] == '') {
            await database.collection('emp').doc(snapshot.id).update({'phone': number}).then((f) {
              print('No Problem');
            }).catchError((error) {
              print('Error');
            });
          }
        }
        signOutGoogle();
        signOutOf();
        Navigator.pushReplacementNamed(context, '/login');
      } on FirebaseAuthException catch (e) {
        print('Failed with code ${e.code}');
        print(e.message);
        switch (e.message) {
          case 'com.google.firebase.FirebaseException: User has already been linked to the given provider.':
            final QuerySnapshot query =
                await database.collection('emp').where('phone', isEqualTo: number).get();
            if (query.size != 0) {
              var snapshot = query.docs[0];
              global.globalSessionData.name = snapshot.data()['Name'];
              global.globalSessionData.email = snapshot.data()['Email'];
              global.globalSessionData.nfcID = snapshot.data()['NfcID'];
              global.globalSessionData.phoneNo = number;
            }
            signOutGoogle();
            signOutOf();
            Navigator.pushReplacementNamed(context, '/login');
            break;
        }
      }
    } else {
      final UserCredential userCredential = await _auth.signInWithCredential(phoneAuthCredential);
      final User usr = userCredential.user;

      if (usr != null) {
        final QuerySnapshot query =
            await database.collection('emp').where('phone', isEqualTo: number).get();
        if (query.size != 0) {
          var snapshot = query.docs[0];
          global.globalSessionData.name = snapshot.data()['Name'];
          global.globalSessionData.email = snapshot.data()['Email'];
          global.globalSessionData.nfcID = snapshot.data()['NfcID'];
          global.globalSessionData.phoneNo = number;
        }
        Navigator.pushReplacementNamed(context, '/user');
      }
    }


  };
  PhoneVerificationFailed verificationFailed = (FirebaseAuthException authException) {
    print(
        'Phone verification failed with code ${authException.code}, message :${authException.message}');
  };
  PhoneCodeSent codeSent = (String verificationId, [int forceResendingToken]) async {
    _verificationId = verificationId;
  };
  PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (String verificationId) {
    _verificationId = verificationId;
  };
  try {
    await _auth.verifyPhoneNumber(
      phoneNumber: number,
      timeout: const Duration(seconds: 60),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
    print('trying here');
  } catch (e) {
    print('Error $e');
  }
}

void signInWithPhoneNumber(BuildContext context, String number, String smscode) async {
  final AuthCredential credential = PhoneAuthProvider.credential(
    verificationId: _verificationId,
    smsCode: smscode,
  );
  var email;

  User checking = _auth.currentUser;
  try {
    if (checking != null) {
      email = checking.email;
      await checking.linkWithCredential(credential);
      checking.updatePhoneNumber(credential);
      final QuerySnapshot query =
          await database.collection('emp').where('Email', isEqualTo: email).get();
      if (query.size != 0) {
        var snapshot = query.docs[0];
        database.collection('emp').doc(snapshot.id).update({'phone': number}).then((value) {
          print('User Updated');
          global.globalSessionData.phoneNo = number;
        }).catchError((error) {
          print('User not updated');
        });
      }
    } else {
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User user = userCredential.user;

      if (user != null) {
        final QuerySnapshot query =
            await database.collection('emp').where('phone', isEqualTo: number).get();
        if (query.size != 0) {
          var snapshot = query.docs[0];
          global.globalSessionData.name = snapshot.data()['Name'];
          user.updateProfile(displayName: global.globalSessionData.name);
          global.globalSessionData.email = snapshot.data()['Email'];
          user.updateEmail(global.globalSessionData.email);
          global.globalSessionData.myId = snapshot.id;
          global.globalSessionData.nfcID = snapshot.data()['NfcID'];
          global.globalSessionData.phoneNo = number;
        }
      }
    }
  } on FirebaseAuthException catch (e) {
    print('Failed with code ${e.code}');
    print(e.message);
    switch (e.message) {
      case 'com.google.firebase.FirebaseException: User has already been linked to the given provider.':
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User user = userCredential.user;
        if (user != null) {
          final QuerySnapshot query =
              await database.collection('emp').where('phone', isEqualTo: user.phoneNumber).get();
          if (query.size != 0) {
            var snapshot = query.docs[0];
            global.globalSessionData.name = snapshot.data()['Name'];
            global.globalSessionData.email = snapshot.data()['Email'];
            global.globalSessionData.nfcID = snapshot.data()['NfcID'];
            global.globalSessionData.phoneNo = number;
          }
        } else {}
        break;
    }
  }
}
// SizedBox(height: 300),
//GOOGLE SIGN IN
/*OutlineButton(
                //returns outline button
                splashColor: Colors.grey,
                onPressed: () async {
                  checkLogin = await checkBiometric();
                  if (checkLogin != false) {
                    // signOutGoogle();
                    signInWithGoogle().then((result) {
                      if (result != null) {
                        // locationData();
                        print('$result');
                        Navigator.pushReplacementNamed(context, '/attendancePanel');
                      } else {
                        print('Error logging in, user does not exist in employee table');
                        signOutGoogle();
                        exit(0);
                      }
                    });
                  }
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                highlightElevation: 0,
                borderSide: BorderSide(color: Colors.grey),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'Login to Lyfas attendance app',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),*/
