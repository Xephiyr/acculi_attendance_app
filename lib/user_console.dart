import 'package:acculi_attendance_app/attendance_tab.dart';
import 'package:acculi_attendance_app/current_task.dart';
import 'package:acculi_attendance_app/leave_request.dart';
import 'package:acculi_attendance_app/mapping.dart';
import 'package:acculi_attendance_app/marker_add.dart';
import 'package:acculi_attendance_app/user_panel_tab.dart';
import 'package:acculi_attendance_app/work_tasks_tab.dart';
import 'package:flutter/material.dart';

class UserConsole extends StatefulWidget {
  @override
  _UserConsoleState createState() => _UserConsoleState();
}

Map<int, String> path = {0: 'Attendance', 1: 'Home', 2: 'Task'};
final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class _UserConsoleState extends State<UserConsole> {
  /*final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();*/
  int _currentIndex = 1;

  List<Widget> _children = <Widget>[
    AttendanceTab(),
    UserPage(),
    TaskTab(),
  ];

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.hourglass_bottom_sharp),
          label: 'Attendance',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_pin),
          label: 'Tasks',
        ),
      ],
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      selectedItemColor: Colors.black,
      iconSize: 40,
      onTap: (int index) {
        setState(() {
          _currentIndex = index;
        });

        /*_navigatorKey.currentState.pushReplacementNamed(path[index]);*/
      },
      elevation: 5,
    );
  }

  /*Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case 'Attendance':
        return MaterialPageRoute(builder: (context) => AttendanceTab());
      case 'Task':
        return MaterialPageRoute(builder: (context) => TaskTab());
      default:
        return MaterialPageRoute(builder: (context) => UserPage());
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: <String, WidgetBuilder>{
        '/map': (BuildContext context) => MapCaller(),
        '/leave': (BuildContext context) => LeaveForm(),
        '/history': (BuildContext context) => ShowHistory(),
        '/current': (BuildContext context) => CurrentTask(),
        '/marker': (BuildContext context) => MapMarker(),
      },
      home: Scaffold(
        appBar: AppBar(
          title: Text(path[_currentIndex].toString()),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.info),
              tooltip: 'Show info',
              onPressed: () {
                _settingModalBottomSheet(context);
              },
            ),
          ],
          backgroundColor: Colors.lightBlueAccent,
          elevation: 0.0,
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: _children,
        ),
        bottomNavigationBar: _bottomNavigationBar(),
      ),
      navigatorKey: navigatorKey,
    );
  }
}

void _settingModalBottomSheet(context) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: new Wrap(
            children: <Widget>[
              new ListTile(
                title: new Text(
                    'Attendii - Indigenious Attendance App of Acculi Labs Pvt. Ltd.'),
                subtitle: new Text(
                    'Tailormade for multi-location, flexible working hours, hybrid device usage:- work from home, field operation setup'),
                isThreeLine: true,
              ),
            ],
          ),
        );
      });
}
