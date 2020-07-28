import 'package:flutter/material.dart';
import 'package:phoenixcms/models/schema_model.dart';
import 'package:provider/provider.dart';

class AddTypeDialog extends StatefulWidget {
  final String collectionId;
  AddTypeDialog(this.collectionId);

  @override
  State<StatefulWidget> createState() {
    return AddTypeDialogState(collectionId);
  }
}

class AddTypeDialogState extends State<AddTypeDialog> {
  final String collectionId;
  String typeName = '';
  String typeId = '';

  AddTypeDialogState(this.collectionId);

  @override
  Widget build(BuildContext context) {
    return Consumer<SchemaModel>(
      builder: (BuildContext context, SchemaModel schema, Widget child) {
        return SimpleDialog(
          children: [
            Text('Type Name'),
            TextField(
              onChanged: (String value) {
                typeName = value;
              },
            ),
            Text('Type ID (or leave blank to use default'),
            TextField(
              onChanged: (String value) {
                typeId = value;
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
                        onPressed: () async {
                          await schema.addType(collectionId, typeName, typeId);
                          Navigator.pop(context);
                        });
                  },
                )
              ],
            )
          ],
        );
      },
    );
  }
}
