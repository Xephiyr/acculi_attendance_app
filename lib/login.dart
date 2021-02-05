import 'package:flutter/material.dart';
import 'package:acculi_attendance_app/biometric.dart';
import 'package:acculi_attendance_app/sign_in.dart';

//TODO: add firebase for location/attendance
class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool checkLogin;

  @override
  void initState() {
    super.initState();
  }

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
                        Navigator.pushReplacementNamed(context, '/user');
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
              Padding(
                padding: const EdgeInsets.only(left: 100, right: 100, bottom: 10),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FlatButton(
                    //returns outline button
                    splashColor: Colors.grey,
                    onPressed: () async {
                      Navigator.pushReplacementNamed(context, '/phone');
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Login with phone',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
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
