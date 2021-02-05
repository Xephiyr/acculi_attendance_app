import 'package:cloud_firestore/cloud_firestore.dart';

class Work {
  bool completed;

  int hoursneeded;
  int task;
  String workId;
  GeoPoint workLatLng;
  String message;

  Work(this.completed, this.hoursneeded, this.task, this.workId,
      this.workLatLng) {
    print("######################################");
    print("Some Shit i init " +
        this.completed.toString() +
        "   " +
        this.hoursneeded.toString() +
        "   " +
        this.task.toString() +
        "" +
        this.workId +
        "   " +
        this.workLatLng.toString());
  }
}

class WorkTest {
  bool completed;

  int hoursneeded;
  int task;
  List<String> workId = new List(4);
  GeoPoint workLatLng;
  String message;
  String docID;
  int count;
  WorkTest(this.completed, this.task, this.workLatLng, this.docID) {
    completed = this.completed;
    task = this.task;
    workLatLng = this.workLatLng;

    print("######################################");
    /*print("Some Shit i init " +
        this.completed.toString() +
        "   " +
        this.hoursneeded.toString() +
        "   " +
        this.task.toString() +
        "" +
        this.workId[0] +
        "" +
        this.workId[1] +
        "" +
        this.workId[2] +
        "" +
        this.workId[3] +
        "" +
        "   " +
        this.workLatLng.toString());
    arrWorkId = this.workId[0] + "," + this.workId[1] + "," + this.workId[2] + "," + this.workId[3];*/
  }
}

class Position {
  String mail;
  GeoPoint location;
  DateTime time;
  String name;

  Position(this.mail, this.location, this.name, this.time) {
    print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
    print("Initialising position object with");
    print(this.mail);
    print(this.location);
    print(this.name);
    print(this.time);

    print("Completed init of position object");
    print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
  }
}
