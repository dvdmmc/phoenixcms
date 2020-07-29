import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final Firestore firestore = Firestore.instance;

const Map<String, int> PHOENIXCMS_PERMISSION_LEVELS = {
  'owner': 5,
  'admin': 4,
  'editor': 3,
  'creator': 2,
  'viewer': 1
};

class UserModel extends ChangeNotifier {
  FirebaseUser _user;
  FirebaseUser get user => _user;
  PhoenixCMSUser _phxUser;
  PhoenixCMSUser get phxUser => _phxUser;

  void currentUser() async {
    _user = await auth.currentUser();
    notifyListeners();
  }

  Future<AuthResult> signInWithEmailAndPassword(
      String email, String password) async {
    AuthResult authResult =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    DocumentSnapshot phoenixUser = await firestore
        .collection("phoenixcms_users")
        .document(authResult.user.uid)
        .get();
    if (phoenixUser.data == null) {
      return null;
    }
    _phxUser = PhoenixCMSUser(
        phoenixUser.documentID, phoenixUser.data['permissionLevel']);
    _user = authResult.user;
    notifyListeners();
    return authResult;
  }
}

class PhoenixCMSUser {
  final String uid;
  final String permissionLevel;
  PhoenixCMSUser(this.uid, this.permissionLevel);
  bool isAllowed(String permissionLevel) {
    if (PHOENIXCMS_PERMISSION_LEVELS[this.permissionLevel] >=
        PHOENIXCMS_PERMISSION_LEVELS[permissionLevel]) {
      return true;
    } else
      return false;
  }
}
