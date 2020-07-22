import 'package:flutter/material.dart';
import 'package:phoenixcms/forms/data_entry_form.dart';
import 'package:phoenixcms/models/schema_model.dart';
import 'package:provider/provider.dart';

class DataEntryDialog extends StatefulWidget {
  final String collectionId;
  final String docId;
  final Map<String, dynamic> docData;

  DataEntryDialog(this.collectionId, this.docId, this.docData);

  @override
  State<StatefulWidget> createState() {
    return DataEntryDialogState(collectionId, docId, docData);
  }
}

class DataEntryDialogState extends State<DataEntryDialog> {
  final String collectionId;
  final String docId;
  final Map<String, dynamic> docData;

  DataEntryDialogState(this.collectionId, this.docId, this.docData);
  @override
  Widget build(BuildContext context) {
    return Consumer<SchemaModel>(
        builder: (BuildContext context, SchemaModel schema, Widget child) {
      return StreamBuilder(
        stream: schema.streamCollectionFields(collectionId),
        builder: (BuildContext context,
            AsyncSnapshot<List<PhoenixCMSField>> fields) {
          List<Widget> _children;

          if (!fields.hasData) {
            _children = [
              Center(
                child: Text("Loading..."),
              )
            ];
          } else {
            _children = [
              DataEntryForm(collectionId, fields.data, docId, docData)
            ];
          }
          return SimpleDialog(
            children: _children,
          );
        },
      );
    });
  }
}
