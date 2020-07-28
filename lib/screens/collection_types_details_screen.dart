import 'package:flutter/material.dart';
import 'package:phoenixcms/dialogs/add_type_dialog.dart';
import 'package:phoenixcms/models/schema_model.dart';
import 'package:provider/provider.dart';

class CollectionTypesDetailsScreen extends StatelessWidget {
  static const routeName = '/collection-types-details';

  @override
  Widget build(BuildContext context) {
    Map<String, String> args =
        ModalRoute.of(context).settings.arguments as Map<String, String>;
    final String id = args['id'];
    return Scaffold(
      body: Consumer<SchemaModel>(
        builder: (context, SchemaModel schema, child) {
          return StreamBuilder(
            stream: schema.streamCollectionFields(id),
            builder: (context, AsyncSnapshot<List<PhoenixCMSField>> fields) {
              return StreamBuilder(
                  stream: schema.streamCollectionTypes(id),
                  builder:
                      (context, AsyncSnapshot<List<PhoenixCMSType>> types) {
                    if (fields.data == null || types.data == null) {
                      return Scaffold(
                        body: Center(
                          child: Text("Loading"),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        Row(
                          children: [Text("Types")],
                        ),
                        DataTable(columns: <DataColumn>[
                          DataColumn(label: Text("Field")),
                          for (PhoenixCMSType _type in types.data)
                            DataColumn(label: Text(_type.name))
                        ], rows: <DataRow>[
                          for (PhoenixCMSField _field in fields.data)
                            DataRow(cells: <DataCell>[
                              DataCell(Text(_field.fieldName)),
                              for (PhoenixCMSType _type in types.data)
                                DataCell(Checkbox(
                                    value: _type.fields.indexOf(_field.id) >= 0,
                                    onChanged: (bool value) async {
                                      await schema.updateTypeFieldValue(
                                          id, _type.id, _field.id, value);
                                    }))
                            ])
                        ])
                      ],
                    );
                  });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: const Text('+'),
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AddTypeDialog(id);
              },
            );
          }),
    );
  }
}
