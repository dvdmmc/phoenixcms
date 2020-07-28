import 'package:flutter/material.dart';
import 'package:phoenixcms/config/phoenixcms_config.dart';
import 'package:phoenixcms/menus/phoenixcms_drawer.dart';
import 'package:phoenixcms/models/user_model.dart';
import 'package:phoenixcms/screens/schema_overview_screen.dart';
import 'package:provider/provider.dart';

import 'data_overview_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (BuildContext context, UserModel user, Widget child) {
        if (user.user == null) {
          Navigator.of(context).popAndPushNamed('/');
          return Scaffold(
            body: Center(
                child: Text("Need to login in order to access this page")),
          );
        }
        return Scaffold(
            appBar: AppBar(title: const Text(PHOENIXCMS_TITLE)),
            drawer: PhoenixCMSDrawer(),
            body: Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 150,
                  width: 150,
                  padding: const EdgeInsets.all(8.0),
                  child: ButtonTheme(
                    minWidth: 150,
                    height: 150,
                    child: RaisedButton(
                        child: Text("Data"),
                        onPressed: () {
                          Navigator.pushNamed(
                              context, DataOverviewScreen.routeName);
                        }),
                  ),
                ),
                Container(
                  height: 150,
                  width: 150,
                  padding: const EdgeInsets.all(8.0),
                  child: ButtonTheme(
                    minWidth: 150,
                    height: 150,
                    child: RaisedButton(
                        child: Text("Schema"),
                        onPressed: user.phxUser.isAllowed("admin")
                            ? () {
                                Navigator.pushNamed(
                                    context, SchemaOverviewScreen.routeName);
                              }
                            : null),
                  ),
                )
              ],
            )));
      },
    );
  }
}
