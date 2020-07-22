import 'package:flutter/material.dart';
import 'package:phoenixcms/menus/phoenixcms_drawer.dart';
import 'package:phoenixcms/models/schema_model.dart';
import 'package:phoenixcms/models/user_model.dart';
import 'package:provider/provider.dart';

class CollectionDetailsScreen extends StatefulWidget {
  static const routeName = '/collection-details';

  @override
  State<StatefulWidget> createState() {
    return CollectionDetailsState();
  }
}

class CollectionDetailsState extends State<CollectionDetailsScreen> {
  // TODO change back to Stateless widget?
  @override
  Widget build(BuildContext context) {
    Map<String, String> args =
        ModalRoute.of(context).settings.arguments as Map<String, String>;
    final String id = args['id'];
    return Consumer2<UserModel, SchemaModel>(builder: (BuildContext context,
        UserModel user, SchemaModel schema, Widget child) {
      if (user.user == null) {
        Navigator.of(context).popAndPushNamed('/');
        return Scaffold(
          body:
              Center(child: Text("Need to login in order to access this page")),
        );
      }
      return StreamBuilder(
          stream: schema.streamCollectionSchema(id),
          builder: (BuildContext context,
              AsyncSnapshot<PhoenixCMSCollection> collection) {
            return StreamBuilder(
                stream: schema.streamCollectionFields(id),
                builder:
                    (context, AsyncSnapshot<List<PhoenixCMSField>> fields) {
                  if (collection.data == null || fields.data == null) {
                    return Scaffold(body: Center(child: Text("Loading 2")));
                  }
                  return Scaffold(
                      appBar: AppBar(title: const Text('Phoenix CMS')),
                      drawer: PhoenixCMSDrawer(),
                      body: Center(
                          child: Center(
                              child: Column(
                        children: [
                          Text(collection.data.collectionName),
                          for (PhoenixCMSField _field in fields.data)
                            Row(
                              children: [
                                Text(_field.fieldName),
                                RaisedButton(
                                    child: Text('Details'),
                                    onPressed: () {
                                      // Navigator.pushNamed(
                                      //     context, FieldDetailsScreen.routeName,
                                      //     arguments: {'id': _field.id});
                                    }),
                                RaisedButton(
                                    child: Text('Delete'),
                                    onPressed: () {
                                      // TODO Delete
                                    })
                              ],
                            )
                        ],
                      ))),
                      floatingActionButton: FloatingActionButton(
                        onPressed: () async {
                          var result = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                String _fieldType;
                                return StatefulBuilder(
                                    builder: (context, setState) {
                                  return SimpleDialog(
                                    title: Text('New Field'),
                                    children: [
                                      Text('Field Name'),
                                      TextField(
                                        onChanged: (String value) {
                                          schema.fieldName = value;
                                        },
                                      ),
                                      Text(
                                          'Firestore Field (or leave blank to use default'),
                                      TextField(
                                        onChanged: (String value) {
                                          schema.firestoreFieldName = value;
                                        },
                                      ),
                                      DropdownButton<String>(
                                        value: _fieldType,
                                        hint: Text('Choose a type'),
                                        onChanged: (value) {
                                          setState(() {
                                            _fieldType = value;
                                          });
                                        },
                                        items: <String>[
                                          // TODO move this to schema_model
                                          'List',
                                          'Map',
                                          'Text',
                                          'Bool',
                                          'Number',
                                          'Timestamp',
                                          'Type'
                                        ]
                                            .map<DropdownMenuItem<String>>(
                                                (String value) =>
                                                    DropdownMenuItem(
                                                        child: Text(value),
                                                        value: value
                                                            .toLowerCase()))
                                            .toList(),
                                      ),
                                      Row(
                                        children: [
                                          RaisedButton(
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                schema.fieldName = null;
                                                schema.firestoreFieldName =
                                                    null;
                                                setState(() {
                                                  _fieldType = null;
                                                });
                                                ;
                                                Navigator.pop(context);
                                              }),
                                          RaisedButton(
                                              child: Text('Add'),
                                              onPressed: _fieldType == null
                                                  ? null
                                                  : () async {
                                                      await schema.addField(
                                                          id, _fieldType);
                                                      schema.fieldName = null;
                                                      schema.firestoreFieldName =
                                                          null;
                                                      setState(() {
                                                        _fieldType = null;
                                                      });
                                                      Navigator.pop(context);
                                                    })
                                          // _getAddButton(schema, id, context))
                                        ],
                                      )
                                    ],
                                  );
                                });
                              });
                        },
                        child: const Text('+'),
                      ));
                });
          });
    });
  }
}
