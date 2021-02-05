import 'package:flutter/material.dart';
import 'package:acculi_attendance_app/biometric.dart';
import 'package:acculi_attendance_app/sign_in.dart';

//TODO: add firebase for location/attendance
class FirstLogin extends StatefulWidget {
  @override
  _FirstLoginState createState() => _FirstLoginState();
}

class _FirstLoginState extends State<FirstLogin> {
  bool checkLogin;

  @override
  Widget build(BuildContext context) {
    MediaQueryData deviceInfo = MediaQuery.of(context);
    return Scaffold(
      body: Container(
        width: deviceInfo.size.width,
        height: deviceInfo.size.height,
        decoration: BoxDecoration(
          color: Colors.white,
          image: const DecorationImage(image: AssetImage("assets/lyfas-attendance-bg.png")),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 300),
              OutlineButton(
                //returns outline button
                splashColor: Colors.grey,
                onPressed: () async {
                  checkLogin = await checkBiometric();
                  if (checkLogin != false) {
                    signInWithGoogle().then((result) {
                      if (result != null) {
                        // locationData();
                        print('$result');
                        setBoolInSharedPref();
                        Navigator.pushReplacementNamed(context, '/phone');
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
