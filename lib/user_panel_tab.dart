import 'dart:io';

import 'package:acculi_attendance_app/sign_in.dart';
import 'package:acculi_attendance_app/the_user.dart' as global;
import 'package:acculi_attendance_app/user_console.dart';
import 'package:flutter/material.dart';

/*
* import 'package:acculi_attendance_app/nfc_auth.dart';
* import 'package:acculi_attendance_app/sign_in.dart';
*/
String name = global.globalSessionData.name;

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    name = name[0].toUpperCase() + name.substring(1);
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Card(
                elevation: 5,
                child: ListTile(
                  title: Text('Name : ' + name),
                  subtitle: Text('NfcID : ' +
                      global.globalSessionData.nfcID +
                      "\n" +
                      "Email : " +
                      global.globalSessionData.email +
                      "\n" +
                      "Phone :" +
                      global.globalSessionData.phoneNo),
                  isThreeLine: true,
                ),
              ),
            ),
          ),
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              child: ListTile(
                  leading: Icon(Icons.calendar_today_outlined),
                  title: Text("Apply for leave"),
                  onTap: () {
                    navigatorKey.currentState.pushNamed('/leave');
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              child: ListTile(
                  leading: Icon(Icons.calendar_today_outlined),
                  title: Text("View leave history"),
                  onTap: () {
                    navigatorKey.currentState.pushNamed('/history');
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              child: ListTile(
                  leading: Icon(Icons.add_location_alt),
                  title: Text("Add new task marker"),
                  onTap: () {
                    print('MARKER ADDITION PAGE');
                    navigatorKey.currentState.pushNamed('/marker');
                  }),
            ),
          ),
          SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Card(
                child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text("Logout"),
                    onTap: () async {
                      await signOutOf();
                      exit(0);
                    }),
              ),
            ),
          ),
          //Add buttons here
        ],
      ),
    );
  }
}
