import 'package:flutter/material.dart';
import 'package:phoenixcms/menus/phoenixcms_drawer.dart';
import 'package:phoenixcms/models/schema_model.dart';
import 'package:phoenixcms/models/user_model.dart';
import 'package:provider/provider.dart';

class DataEntryScreen extends StatefulWidget {
  static const routeName = '/data-entry';
  @override
  State<StatefulWidget> createState() {
    return DataEntryScreenState();
  }
}

class DataEntryScreenState extends State<DataEntryScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<UserModel, SchemaModel>(
      builder: (BuildContext context, UserModel user, SchemaModel schema,
          Widget child) {
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
            body: Center(child: Text('Form entry')));
      },
    );
  }
}
