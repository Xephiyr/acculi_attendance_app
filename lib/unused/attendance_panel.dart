import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:acculi_attendance_app/sign_in.dart';

String email;
final FirebaseAuth auth = FirebaseAuth.instance;
final User user = auth.currentUser;

class ShowAttendance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('GroundTeam Attendance Check'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RaisedButton(
                child: Text('User Console'),
                onPressed: () async {
                  Navigator.pushNamed(context, '/user');
                },
              ),
              Spacer(),
              RaisedButton(
                child: Text('Apply for Leave'),
                onPressed: () async {
                  Navigator.pushNamed(context, '/leave', arguments: user.email);
                },
              ),
              Spacer(),
              RaisedButton(
                child: Text('View available Tasks Live'),
                onPressed: () async {
                  Navigator.pushNamed(context, '/task');
                },
              ),
              Spacer(),
              RaisedButton(
                child: Text('userpage test'),
                onPressed: () async {
                  Navigator.pushNamed(context, '/usr');
                },
              ),
              Spacer(),
              RaisedButton(
                child: Text('Live attendance'),
                onPressed: () async {
                  Navigator.pushNamed(context, '/att');
                },
              ),
              Spacer(),
              RaisedButton(
                child: Text('Logout'),
                onPressed: () async {
                  showDialog(
                    builder: (BuildContext context) {
                      return AlertDialog(
                          title: Text("Logout"),
                          content: Column(
                            children: [
                              Text("Do you Really want to logout?"),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RaisedButton(
                                    child: Text("Cancel"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  RaisedButton(
                                    child: Text("Logout"),
                                    onPressed: () async {
                                      await signOutGoogle();
                                      exit(0);
                                    },
                                  )
                                ],
                              ),
                            ],
                          ));
                    },
                    context: context,
                  );
                },
              )
            ],
          ),
        ),
      );
    }
  }
}
