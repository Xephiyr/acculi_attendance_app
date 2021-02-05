import 'package:acculi_attendance_app/login.dart';
import 'package:acculi_attendance_app/login_first.dart';
import 'package:acculi_attendance_app/nfc_auth.dart';
import 'package:acculi_attendance_app/phone_auth.dart';
import 'package:acculi_attendance_app/sign_in.dart';
import 'package:acculi_attendance_app/user_console.dart';
import 'package:flutter/material.dart';

bool firstcheck;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  firstcheck = await getBoolFromSharedPref();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: <String, WidgetBuilder>{
        '/nfc': (BuildContext context) => NfcAuthentication(),
        '/user': (BuildContext context) => UserConsole(),
        '/phone': (BuildContext context) => PhoneAuth(),
        '/login': (BuildContext context) => Login(),
      },
      home: firstcheck ? Login() : FirstLogin(),
    );
  }
}
// '/attendancePanel': (BuildContext context) => ShowAttendance(),
// '/display': (BuildContext context) => ShowDisplay(),
// '/att': (BuildContext context) => AttendaceShowerStream(),
// '/dash': (BuildContext context) => Dashboard(),
// '/task': (BuildContext context) => TaskBoard(),
// '/mail': (BuildContext context) => LoginForm(),
// '/usr': (BuildContext context) => UserPage(),
// '/first': (BuildContext context) => FirstLogin(),
