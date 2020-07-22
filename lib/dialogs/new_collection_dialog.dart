import 'package:flutter/material.dart';
import 'package:phoenixcms/models/schema_model.dart';
import 'package:provider/provider.dart';

class NewCollectionDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NewCollectionDialogState();
  }
}

class NewCollectionDialogState extends State<NewCollectionDialog> {
  String collectionName = '';
  String firestoreName;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('New Collection'),
      children: [
        Text('Collection Name'),
        TextField(
          onChanged: (String value) {
            collectionName = value;
          },
        ),
        Text('Firestore Collection (or leave blank to use default'),
        TextField(
          onChanged: (String value) {
            firestoreName = value;
          },
        ),
        Row(
          children: [
            RaisedButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                }),
            Consumer<SchemaModel>(
              builder:
                  (BuildContext context, SchemaModel schema, Widget child) {
                return RaisedButton(
                    child: Text('Add'),
                    onPressed: () {
                      schema.addCollection(collectionName, firestoreName);
                      Navigator.pop(context);
                    });
              },
            )
          ],
        )
      ],
    );
  }
}
