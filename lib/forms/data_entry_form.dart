import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phoenixcms/models/schema_model.dart';
import 'package:provider/provider.dart';

class DataEntryForm extends StatefulWidget {
  final PhoenixCMSCollection collection;
  final List<PhoenixCMSField> fields;
  final List<PhoenixCMSType> types;
  final String docId;
  final Map<String, dynamic> docData;

  DataEntryForm(
      this.collection, this.fields, this.types, this.docId, this.docData);

  @override
  State<StatefulWidget> createState() {
    return DataEntryFormState(collection, fields, types, docId, docData);
  }
}

class DataEntryFormState extends State<DataEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final PhoenixCMSCollection collection;
  final List<PhoenixCMSField> fields;
  final List<PhoenixCMSType> types;
  final String docId;
  final Map<String, dynamic> docData;
  Map formInputs = Map<String, dynamic>();
  Map fieldTypes = Map<String, String>();
  Set<String> choices = Set<String>();
  Map<String, DateTime> selectedDates = {};
  PhoenixCMSType _selectedType;

  DataEntryFormState(
      this.collection, this.fields, this.types, this.docId, this.docData);
  @override
  Widget build(BuildContext context) {
    List<Widget> formFields = fieldsToFormFields(fields, types, collection);
    formFields.add(Consumer<SchemaModel>(
      builder: (BuildContext context, SchemaModel schema, Widget child) {
        return RaisedButton(
          onPressed: () async {
            if (collection.typeDataField != null && _selectedType != null) {
              formInputs[collection.typeDataField] = _selectedType.id;
              fieldTypes[collection.typeDataField] = 'text';
            }
            bool success = await schema.saveData(collection, docId, formInputs,
                fieldTypes, choices, selectedDates);
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

  List<Widget> fieldsToFormFields(List<PhoenixCMSField> fields,
      List<PhoenixCMSType> types, PhoenixCMSCollection collection) {
    List _list = List<Widget>();
    if (types.length > 0) {
      if (_selectedType == null) {
        if (docData != null && docData.containsKey(collection.typeDataField)) {
          for (PhoenixCMSType _type in types) {
            if (_type.id == docData[collection.typeDataField]) {
              _selectedType = _type;
            }
          }
        } else {
          _selectedType = types[0];
        }
      }

      _list.add(DropdownButton<String>(
        value: _selectedType.id,
        hint: Text('Choose a type'),
        onChanged: (value) {
          setState(() {
            for (PhoenixCMSType _type in types) {
              if (_type.id == value) {
                _selectedType = _type;
              }
            }
          });
        },
        items: types
            .map<DropdownMenuItem<String>>((PhoenixCMSType value) =>
                DropdownMenuItem(child: Text(value.name), value: value.id))
            .toList(),
      ));
    }
    fields.forEach((PhoenixCMSField _field) {
      setState(() {
        fieldTypes[_field.id] = _field.fieldType;
      });
      String _iv;
      if (docData != null && docData.containsKey(_field.id)) {
        _iv = docData[_field.id].toString();
      }
      switch (_field.fieldType) {
        case ("text"):
        case ("number"):
          if (_selectedType == null ||
              _selectedType.fields.contains(_field.id)) {
            _list.add(TextFormField(
                initialValue: _iv,
                onChanged: (value) {
                  setState(() {
                    formInputs[_field.id] = value;
                  });
                },
                decoration: InputDecoration(labelText: _field.fieldName)));
          } else {
            formInputs.remove(_field.id);
          }

          break;
        case ("bool"):
          if (_selectedType == null ||
              _selectedType.fields.contains(_field.id)) {
            setState(() {
              if (formInputs[_field.id] == null) {
                if (docData != null && docData.containsKey(_field.id)) {
                  formInputs[_field.id] = docData[_field.id];
                } else {
                  formInputs[_field.id] = true;
                }
              }
            });
            _list.add(Row(
              children: [
                Text("${_field.fieldName} True/False"),
                ChoiceChip(
                  label: Text("True"),
                  selected: formInputs[_field.id],
                  onSelected: (value) {
                    setState(() {
                      formInputs[_field.id] = value;
                    });
                  },
                ),
                ChoiceChip(
                  label: Text("False"),
                  selected: !formInputs[_field.id],
                  onSelected: (value) {
                    setState(() {
                      formInputs[_field.id] = !value;
                    });
                  },
                )
              ],
            ));
          } else {
            formInputs.remove(_field.id);
          }

          break;
        case ("multi"):
          if (_selectedType == null ||
              _selectedType.fields.contains(_field.id)) {
            _list.add(Text("${_field.fieldName} Choice"));
            setState(() {
              if (!formInputs.containsKey(_field.id)) {
                if (docData != null && docData.containsKey(_field.id)) {
                  docData[_field.id].forEach((element) {
                    choices.add(element);
                  });
                }
              }
              formInputs[_field.id] = true;
            });
            _field.choices.forEach((element) {
              _list.add(CheckboxListTile(
                title: Text(element.toString()),
                value: choices.contains(element.toString()),
                onChanged: (value) {
                  setState(() {
                    // TODO support multiple choices on same form
                    if (value) {
                      choices.add(element);
                    } else {
                      choices.remove(element);
                    }
                  });
                },
              ));
            });
          } else {
            formInputs.remove(_field.id);
          }

          break;
        case ("timestamp"):
          if (_selectedType == null ||
              _selectedType.fields.contains(_field.id)) {
            _list.add(Text("${_field.fieldName} Date"));
            setState(() {
              formInputs[_field.id] = true;
              if (!selectedDates.containsKey(_field.id)) {
                if (docData != null && docData.containsKey(_field.id)) {
                  selectedDates[_field.id] = docData[_field.id].toDate();
                } else {
                  selectedDates[_field.id] = DateTime.now();
                }
              }
            });
            _list.add(Row(
              children: [
                Text("${DateFormat.yMd().format(selectedDates[_field.id])}"),
                SizedBox(
                  height: 20.0,
                ),
                RaisedButton(
                  onPressed: () async {
                    final DateTime selectedDate = await showDatePicker(
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                      context: context,
                      initialDate: selectedDates[_field.id],
                    );
                    if (selectedDate != null) {
                      setState(() {
                        selectedDates[_field.id] = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedDates[_field.id].hour,
                            selectedDates[_field.id].minute);
                      });
                    }
                  },
                  child: Text('Select date'),
                )
              ],
            ));
            _list.add(Row(
              children: [
                Text("${DateFormat.Hm().format(selectedDates[_field.id])}"),
                SizedBox(
                  height: 20.0,
                ),
                RaisedButton(
                  onPressed: () async {
                    final TimeOfDay selectedTime = await showTimePicker(
                      initialTime: TimeOfDay.now(),
                      context: context,
                    );
                    if (selectedTime != null) {
                      setState(() {
                        selectedDates[_field.id] = DateTime(
                            selectedDates[_field.id].year,
                            selectedDates[_field.id].month,
                            selectedDates[_field.id].day,
                            selectedTime.hour,
                            selectedTime.minute);
                      });
                    }
                  },
                  child: Text('Select Time'),
                )
              ],
            ));
          } else {
            formInputs.remove(_field.id);
          }

          break;
      }
    });
    return _list;
  }
}
