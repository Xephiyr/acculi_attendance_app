import 'package:acculi_attendance_app/the_user.dart' as global;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
var database = FirebaseFirestore.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
bool num;
bool done;
String name;
String email;
String imageUrl;

//String _verificationId;

/*Future<String> signInEmail(String semail, String spassword) async {
  global.clearSessionData();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  final AuthCredential cred = EmailAuthProvider.credential(email: semail, password: spassword);
  final UserCredential authResult = await _auth.signInWithCredential(cred);
  final User user = authResult.user;

  String msg;

  if (user != null) {
    global.globalSessionData.email = user.email;
    global.globalSessionData.name = user.displayName;
    final QuerySnapshot query =
        await database.collection('emp').where('Email', isEqualTo: semail).get();
    if (query.size != 0) {
      var snapshot = query.docs[0];
      global.globalSessionData.nfcID = snapshot.data()['NfcID'];
      global.globalSessionData.myId = snapshot.id;
      global.globalSessionData.toData();

      msg = '$user';
    } else {
      msg = null;
    }

    return msg;
  }
  return null;
}

Future<String> registerEmail(String email, String password, String name) async {
  await Firebase.initializeApp();

  final User user = (await _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  ))
      .user;
  if (user != null) {
    final QuerySnapshot query =
        await database.collection('emp').where('Email', isEqualTo: email).get();
    //check if email is not already in table
    if (query.size == 0) {
      //if no email exists in collection, check if entered name matches entry in table
      final QuerySnapshot querys =
          await database.collection('emp').where('Name', isEqualTo: name).get();
      if (querys.size != 0) {
        var snapshot = querys.docs[0];
        database.collection('emp').doc(snapshot.id).update({'Email': email}).then((value) {
          print('User Updated');
        }).catchError((error) {
          print('User not updated');
        });
      }
    }
    user.updateProfile(displayName: name);
    return '$user';
  } else
    return null;
}

Future<void> signOutEmail() async {
  await _auth.signOut();

  print("User Signed Out");
}*/

Future<String> signInWithGoogle() async {
  await Firebase.initializeApp();
  global.clearSessionData();
  DateTime now = DateTime.now();
  var day = now.day;
  var month = now.month;
  var db = FirebaseFirestore.instance;
  final QuerySnapshot querys = await db
      .collection('position')
      .where('Email', isEqualTo: global.globalSessionData.email)
      .orderBy(
        'Time',
        descending: false,
      )
      .limitToLast(1)
      .get();
  if (querys.size != 0) {
    var snapshot = querys.docs[0];
    DateTime uTime = snapshot.data()['Time'].toDate();
    print(uTime.toString());
    var uDay = uTime.day;
    var uMonth = uTime.month;
    bool checking;
    if (day == uDay) {
      if (month == uMonth) {
        checking = false;
      }
      if (month != uMonth) {
        checking = true;
      }
    } else if (day != uDay) {
      checking = true;
    }
    if (checking == true) {
      global.globalSessionData.logged = false;
    }
    if (checking != true) {
      global.globalSessionData.logged = true;
    }
  }
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final UserCredential authResult =
      await _auth.signInWithCredential(credential);
  final User user = authResult.user;

  if (user != null) {
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);
    assert(user.email != null);
    assert(user.displayName != null);
    assert(user.photoURL != null);

    String msg, phon;
    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);
    name = user.displayName;
    email = user.email;
    phon = user.phoneNumber;
    if (phon == null) phon = "";
    imageUrl = user.photoURL;
    global.globalSessionData.email = email;
    global.globalSessionData.name = name;
    global.globalSessionData.phoneNo = phon;

    print('signInWithGoogle succeeded: $user');
    if (name.contains(" ")) {
      name = name.substring(0, name.indexOf(" "));
    }
    final QuerySnapshot query =
        await database.collection('emp').where('Email', isEqualTo: email).get();

    if (query.size != 0) {
      var snapshot = query.docs[0];
      global.globalSessionData.myId = snapshot.id;
      global.globalSessionData.nfcID = snapshot.data()['NfcID'];
      global.globalSessionData.name = snapshot.data()['Name'];
      msg = '$user';
    }
    if (query.size == 0) {
      final QuerySnapshot querys =
          await database.collection('emp').where('Name', isEqualTo: name).get();
      if (querys.size != 0) {
        var snapshot = querys.docs[0];
        global.globalSessionData.nfcID = snapshot.data()['NfcID'];
        global.globalSessionData.phoneNo = snapshot.data()['phone'];
        database
            .collection('emp')
            .doc(snapshot.id)
            .update({'Email': email}).then((value) {
          print('User Updated');

          msg = '$user';
        }).catchError((error) {
          print('User not updated');
          msg = null;
        });
      }
    }
    global.globalSessionData.toData();
    return msg;
  }

  return null;
}

Future<void> signOutGoogle() async {
  await googleSignIn.signOut();

  print("User Signed Out");
}

Future<void> signOutOf() async {
  await _auth.signOut();

  print("User Signed Out");
}

Future<bool> getBoolFromSharedPref() async {
  final prefs = await SharedPreferences.getInstance();
  final firstCheck = prefs.getBool('firstCheck');
  if (firstCheck == null) {
    return false;
  } else
    return firstCheck;
}

Future<void> setBoolInSharedPref() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('firstCheck', true);
}
