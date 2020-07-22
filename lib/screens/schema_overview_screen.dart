import 'package:flutter/material.dart';
import 'package:phoenixcms/dialogs/new_collection_dialog.dart';
import 'package:phoenixcms/menus/phoenixcms_drawer.dart';
import 'package:phoenixcms/models/schema_model.dart';
import 'package:phoenixcms/models/user_model.dart';
import 'package:provider/provider.dart';

import 'collection_details_screen.dart';

class SchemaOverviewScreen extends StatelessWidget {
  static const routeName = '/schema-overview';

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
        return Consumer<SchemaModel>(
            builder: (BuildContext context, SchemaModel schema, Widget child) {
          List<Widget> collections = List<Widget>();
          schema.collectionList.forEach((PhoenixCMSCollection element) {
            collections.add(Center(
                child: RaisedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, CollectionDetailsScreen.routeName,
                          arguments: {'id': element.id});
                    },
                    child: Text(element.collectionName))));
          });
          return Scaffold(
              appBar: AppBar(title: const Text('Phoenix CMS')),
              drawer: PhoenixCMSDrawer(),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  var result = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return NewCollectionDialog();
                      });
                },
                child: const Text('+'),
              ),
              body: Center(
                  child: GridView.count(
                crossAxisCount: 4,
                children: collections,
              )));
        });
      },
    );
  }
}
