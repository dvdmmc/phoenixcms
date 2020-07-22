import 'package:flutter/material.dart';
import 'package:phoenixcms/models/schema_model.dart';
import 'package:provider/provider.dart';

class DataEntryForm extends StatefulWidget {
  final String collectionId;
  final List<PhoenixCMSField> fields;
  final String docId;
  final Map<String, dynamic> docData;

  DataEntryForm(this.collectionId, this.fields, this.docId, this.docData);

  @override
  State<StatefulWidget> createState() {
    return DataEntryFormState(collectionId, fields, docId, docData);
  }
}

class DataEntryFormState extends State<DataEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final String collectionId;
  final List<PhoenixCMSField> fields;
  final String docId;
  final Map<String, dynamic> docData;
  Map formInputs = Map<String, dynamic>();
  Map fieldTypes = Map<String, String>();

  DataEntryFormState(this.collectionId, this.fields, this.docId, this.docData);

  @override
  Widget build(BuildContext context) {
    List<Widget> formFields = fieldsToFormFields(fields);
    formFields.add(Consumer<SchemaModel>(
      builder: (BuildContext context, SchemaModel schema, Widget child) {
        return RaisedButton(
          onPressed: () async {
            bool success = await schema.saveData(
                collectionId, docId, formInputs, fieldTypes);
            if (success) {
              Navigator.pop(context);
            } else {
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text('Form error...')));
            }
          },
          child: Text("Submit"),
        );
      },
    ));
    return Form(
        key: _formKey,
        child: Column(
          children: formFields,
        ));
  }

  List<Widget> fieldsToFormFields(List<PhoenixCMSField> fields) {
    List _list = List<Widget>();
    fields.forEach((PhoenixCMSField _field) {
      setState(() {
        fieldTypes[_field.id] = _field.fieldType;
      });
      String _iv;
      if (docData != null && docData.containsKey(_field.id)) {
        _iv = docData[_field.id].toString();
      }
      _list.add(TextFormField(
          initialValue: _iv,
          onChanged: (value) {
            setState(() {
              formInputs[_field.id] = value;
            });
          },
          decoration: InputDecoration(labelText: _field.fieldName)));
    });
    return _list;
  }
}
