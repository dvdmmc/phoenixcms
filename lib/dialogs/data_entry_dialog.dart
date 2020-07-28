import 'package:flutter/material.dart';
import 'package:phoenixcms/forms/data_entry_form.dart';
import 'package:phoenixcms/models/schema_model.dart';
import 'package:provider/provider.dart';

class DataEntryDialog extends StatefulWidget {
  final PhoenixCMSCollection collection;
  final String docId;
  final Map<String, dynamic> docData;

  DataEntryDialog(this.collection, this.docId, this.docData);

  @override
  State<StatefulWidget> createState() {
    return DataEntryDialogState(collection, docId, docData);
  }
}

class DataEntryDialogState extends State<DataEntryDialog> {
  final PhoenixCMSCollection collection;
  final String docId;
  final Map<String, dynamic> docData;

  DataEntryDialogState(this.collection, this.docId, this.docData);
  @override
  Widget build(BuildContext context) {
    return Consumer<SchemaModel>(
        builder: (BuildContext context, SchemaModel schema, Widget child) {
      return StreamBuilder(
        stream: schema.streamCollectionTypes(collection.id),
        builder:
            (BuildContext context, AsyncSnapshot<List<PhoenixCMSType>> types) {
          return StreamBuilder(
            stream: schema.streamCollectionFields(collection.id),
            builder: (BuildContext context,
                AsyncSnapshot<List<PhoenixCMSField>> fields) {
              List<Widget> _children;

              if (!fields.hasData || !types.hasData) {
                _children = [
                  Center(
                    child: Text("Loading..."),
                  )
                ];
              } else {
                _children = [
                  DataEntryForm(
                      collection, fields.data, types.data, docId, docData)
                ];
              }
              return SimpleDialog(
                children: _children,
              );
            },
          );
        },
      );
    });
  }
}
