import 'package:flutter/material.dart';
import 'package:phoenixcms/screens/data_overview_screen.dart';
import 'package:phoenixcms/screens/schema_overview_screen.dart';

class PhoenixCMSDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
        title: Text('Schema'),
        onTap: () {
          Navigator.pushNamed(context, SchemaOverviewScreen.routeName);
        },
      ),
    ]));
  }
}
