import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phoenixcms/config/phoenixcms_config.dart';
import 'package:phoenixcms/dialogs/data_entry_dialog.dart';
import 'package:phoenixcms/menus/phoenixcms_drawer.dart';
import 'package:phoenixcms/models/schema_model.dart';
import 'package:phoenixcms/models/user_model.dart';
import 'package:provider/provider.dart';

class DataListScreen extends StatelessWidget {
  static const routeName = '/data-list';
  @override
  Widget build(BuildContext context) {
    Map<String, String> args =
        ModalRoute.of(context).settings.arguments as Map<String, String>;
    final String id = args['id'];
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
        return StreamBuilder(
          stream: schema.streamCollectionSchema(id),
          builder: (context, AsyncSnapshot<PhoenixCMSCollection> collection) {
            return StreamBuilder(
                stream: schema.streamCollectionFields(id),
                builder: (BuildContext context,
                    AsyncSnapshot<List<PhoenixCMSField>> fields) {
                  if (!collection.hasData || !fields.hasData) {
                    return Scaffold(
                        body: Center(child: Text("Loading data...")));
                  }
                  return StreamBuilder(
                      stream: schema.streamCollectionData(id),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<PhoenixCMSDocument>> snapshot) {
                        if (!snapshot.hasData) {
                          return Scaffold(
                              body: Center(child: Text("Loading data...")));
                        }
                        return Scaffold(
                          appBar: AppBar(title: const Text(PHOENIXCMS_TITLE)),
                          drawer: PhoenixCMSDrawer(),
                          body: SingleChildScrollView(
                            child: Container(
                                margin: EdgeInsets.all(200),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Center(
                                        child: Text(
                                          collection.data.collectionName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4,
                                        ),
                                      ),
                                    ),
                                    dataToTable(context, fields.data,
                                        snapshot.data, collection.data),
                                  ],
                                )),
                          ),
                          floatingActionButton: FloatingActionButton(
                              onPressed: user.phxUser
                                      .isAllowed(collection.data.createLevel)
                                  ? () async {
                                      await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return DataEntryDialog(
                                                collection.data, null, null);
                                          });
                                    }
                                  : null,
                              child: const Text('+')),
                        );
                      });
                });
          },
        );
      },
    );
  }

  SingleChildScrollView dataToTable(
      BuildContext context,
      List<PhoenixCMSField> fields,
      List<PhoenixCMSDocument> docs,
      PhoenixCMSCollection collection) {
    fields.sort((PhoenixCMSField fieldA, PhoenixCMSField fieldB) =>
        fieldA.id.compareTo(fieldB.id));
    List columns = List<DataColumn>();
    fields.forEach((PhoenixCMSField field) {
      columns.add(DataColumn(label: Text(field.fieldName)));
    });
    columns.add(DataColumn(label: Text('')));
    List rows = List<DataRow>();
    docs.forEach((PhoenixCMSDocument doc) {
      List cells = List<DataCell>();
      fields.forEach((PhoenixCMSField element) {
        if (doc.data[element.id] != null) {
          if (element.fieldType == "timestamp") {
            cells.add(DataCell(Text(DateFormat.yMd()
                .add_Hm()
                .format(doc.data[element.id].toDate()))));
          } else if (element.fieldType == "multi") {
            cells.add(DataCell(Text(doc.data[element.id].join(", "))));
          } else {
            cells.add(DataCell(Text(doc.data[element.id].toString())));
          }
        } else {
          cells.add(DataCell.empty);
        }
      });
      cells.add(DataCell(Text("Edit"), onTap: () async {
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return DataEntryDialog(collection, doc.id, doc.data);
            });
      }));
      rows.add(DataRow(cells: cells));
    });
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(columns: columns, rows: rows));
  }
}
