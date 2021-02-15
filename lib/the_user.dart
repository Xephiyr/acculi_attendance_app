import 'package:cloud_firestore/cloud_firestore.dart';

class SessionData {
  String email;
  String name;
  String nfcID;
  bool logged = false;
  String myId;
  GeoPoint taskPosition;
  String docid;
  int taskID;
  String taskType;
  String address;
  bool hasPhone;
  String phoneNo;
  String titlemsg; //= 'Current Task ID:';
  String submsg; //= 'Position:';

  void toData() {
    print('*************************************************************');
    print('*****************************1*******************************');
    print('*************************************************************');
    print('Name     :' + name);
    print('Email    :' + email);
    print('NfcID    :' + nfcID);
    print('Has phone?    :' + hasPhone.toString());
    print('Phone number    :' + phoneNo);
    print('*************************************************************');
    print('*****************************1*******************************');
    print('*************************************************************');
  }
}

void clearMessages() {
  globalSessionData.titlemsg = "No Task Selected";
  globalSessionData.submsg = "select a task to display it here";
  globalSessionData.taskType = 'Unspecified Task Type';
}

SessionData globalSessionData;

void clearSessionData() {
  globalSessionData = new SessionData();
  clearMessages();
}
