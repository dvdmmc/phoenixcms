import 'package:flutter/material.dart';
import 'package:phoenixcms/models/user_model.dart';
import 'package:phoenixcms/screens/data_overview_screen.dart';
import 'package:phoenixcms/screens/schema_overview_screen.dart';
import 'package:provider/provider.dart';

class PhoenixCMSDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (BuildContext context, UserModel user, Widget child) {
        return Drawer(
            child: ListView(padding: EdgeInsets.zero, children: <Widget>[
          DrawerHeader(child: Text('Menu')),
          ListTile(
            title: Text('Data'),
            onTap: () {
              Navigator.pushNamed(context, DataOverviewScreen.routeName);
            },
          ),
          ListTile(
            enabled: user.phxUser.isAllowed("admin") ? true : false,
            title: Text('Schema'),
            onTap: () {
              Navigator.pushNamed(context, SchemaOverviewScreen.routeName);
            },
          ),
        ]));
      },
    );
  }
}
