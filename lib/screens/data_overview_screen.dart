import 'package:flutter/material.dart';
import 'package:phoenixcms/config/phoenixcms_config.dart';
import 'package:phoenixcms/menus/phoenixcms_drawer.dart';
import 'package:phoenixcms/models/schema_model.dart';
import 'package:phoenixcms/models/user_model.dart';
import 'package:provider/provider.dart';

import 'data_list_screen.dart';

class DataOverviewScreen extends StatelessWidget {
  static const routeName = '/data-overview';

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserModel, SchemaModel>(builder: (BuildContext context,
        UserModel user, SchemaModel schema, Widget child) {
      if (user.user == null) {
        Navigator.of(context).popAndPushNamed('/');
        return Scaffold(
          body:
              Center(child: Text("Need to login in order to access this page")),
        );
      }
      List<Widget> collections = List<Widget>();
      schema.collectionList.forEach((PhoenixCMSCollection element) {
        collections.add(Center(
            child: ButtonTheme(
          minWidth: 150,
          height: 150,
          child: RaisedButton(
              onPressed: () {
                Navigator.pushNamed(context, DataListScreen.routeName,
                    arguments: {'id': element.id});
              },
              child: Text(element.collectionName)),
        )));
      });
      return Scaffold(
          appBar: AppBar(title: const Text(PHOENIXCMS_TITLE)),
          drawer: PhoenixCMSDrawer(),
          body: Center(
              child: Container(
                  margin: EdgeInsets.all(200),
                  child: GridView.count(
                      crossAxisCount: 4, children: collections))));
    });
  }
}
