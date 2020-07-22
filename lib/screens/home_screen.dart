import 'package:flutter/material.dart';
import 'package:phoenixcms/dialogs/new_collection_dialog.dart';
import 'package:phoenixcms/menus/phoenixcms_drawer.dart';
import 'package:phoenixcms/models/schema_model.dart';
import 'package:phoenixcms/models/user_model.dart';
import 'package:phoenixcms/screens/collection_details_screen.dart';
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
            appBar: AppBar(title: const Text('Phoenix CMS')),
            drawer: PhoenixCMSDrawer(),
            body: Center(
                child: GridView.count(
              crossAxisCount: 4,
              children: [
                RaisedButton(
                    child: Text("Data"),
                    onPressed: () {
                      Navigator.pushNamed(
                          context, DataOverviewScreen.routeName);
                    }),
                RaisedButton(
                    child: Text("Schema"),
                    onPressed: () {
                      Navigator.pushNamed(
                          context, SchemaOverviewScreen.routeName);
                    })
              ],
            )));
      },
    );
  }
}
