import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phoenixcms/models/schema_model.dart';
import 'package:phoenixcms/models/user_model.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  static String email;
  static String password;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
        builder: (BuildContext context, UserModel user, Widget child) {
      MediaQueryData mediaQueryData = MediaQuery.of(context);
      return Scaffold(
        body: Container(
          margin: EdgeInsets.only(
              left: mediaQueryData.size.width / 3,
              right: mediaQueryData.size.width / 3),
          constraints: BoxConstraints(maxWidth: mediaQueryData.size.width / 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                onChanged: (String value) {
                  email = value;
                },
              ),
              TextField(
                obscureText: true,
                onChanged: (String value) {
                  password = value;
                },
              ),
              RaisedButton(
                child: Text("Sign In"),
                onPressed: () async {
                  // add validation
                  AuthResult result =
                      await user.signInWithEmailAndPassword(email, password);
                  // if result ok, navigate to main screen, else show error
                  if (result != null) {
                    // Navigator.pushNamed(context, '/main');
                    Provider.of<SchemaModel>(context, listen: false)
                        .loadCollections();
                    Navigator.pushNamed(context, '/home');
                    // Navigator.of(context).pushNamedAndRemoveUntil(
                    //     '/home', (Route<dynamic> route) => false);
                  }
                },
              )
            ],
          ),
        ),
      );
    });
  }
}
