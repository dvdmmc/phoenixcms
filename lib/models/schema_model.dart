import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recase/recase.dart';

final Firestore firestore = Firestore.instance;

class SchemaModel extends ChangeNotifier {
  List<PhoenixCMSCollection> collectionList = List<PhoenixCMSCollection>();

  String fieldName;
  String firestoreFieldName;

  static const List FIELD_TYPES = <String>[
    'List',
    'Map',
    'Text',
    'Bool',
    'Number',
    'Timestamp',
    'Type',
    'Multi',
    'Single',
    'Image'
  ];

  Future<bool> addCollection(
      String collectionName, String typeDataField, String firestoreName) async {
    try {
      String _firestoreName = firestoreName;
      if (firestoreName == null || firestoreName.trim() == '') {
        _firestoreName = collectionName.snakeCase;
      }
      // TODO allow user override of create level
      Map<String, dynamic> collectionData = {
        'name': collectionName,
        'createLevel': "creator"
      };
      if (typeDataField.trim() != '') {
        collectionData['typeDataField'] = typeDataField;
      }
      await firestore
          .collection('phoenixcms_schema')
          .document(_firestoreName)
          .setData(collectionData);
      collectionList.add(PhoenixCMSCollection(_firestoreName, collectionName,
          typeDataField, "creator")); // TODO allow user override of creator
      notifyListeners();
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> addType(
      String collectionId, String typeName, String typeId) async {
    String _typeId = typeId;
    if (typeId.trim() == '') {
      _typeId = typeName.camelCase;
    }
    try {
      await firestore
          .collection('phoenixcms_schema')
          .document(collectionId)
          .collection('types')
          .document(_typeId)
          .setData({'name': typeName, 'fields': []});
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> addField(
      String collectionId, String fieldType, List<String> choices) async {
    // TODO ensure this field doesn't conflict with existing name (or typeDataField)

    try {
      String _firestoreFieldName = firestoreFieldName;
      if (firestoreFieldName == null || firestoreFieldName.trim() == '') {
        _firestoreFieldName = fieldName.camelCase;
      }
      Map<String, dynamic> fieldData = {'type': fieldType, 'name': fieldName};
      if (fieldType == "list") {
        fieldData['itemType'] = "text";
      }
      if (fieldType == "multi") {
        fieldData['choices'] = choices;
      }
      await firestore
          .collection('phoenixcms_schema')
          .document(collectionId)
          .collection('fields')
          .document(_firestoreFieldName)
          .setData(fieldData);
      return true;
    } catch (err) {
      return false;
    }
  }

  void loadCollections() async {
    collectionList = List<PhoenixCMSCollection>();
    QuerySnapshot qs =
        await firestore.collection('phoenixcms_schema').getDocuments();
    qs.documents.forEach((DocumentSnapshot snap) {
      collectionList.add(PhoenixCMSCollection(
          snap.documentID,
          snap.data['name'],
          snap.data['typeDataField'],
          snap.data['createLevel']));
    });
    notifyListeners();
  }

  Stream<PhoenixCMSCollection> streamCollectionSchema(String id) {
    return firestore
        .collection('phoenixcms_schema')
        .document(id)
        .snapshots()
        .map<PhoenixCMSCollection>((DocumentSnapshot snap) =>
            PhoenixCMSCollection.fromMap(id, snap.data));
  }

  Stream<List<PhoenixCMSType>> streamCollectionTypes(String id) {
    List<PhoenixCMSType> _list = List<PhoenixCMSType>();
    return firestore
        .collection('phoenixcms_schema')
        .document(id)
        .collection('types')
        .snapshots()
        .map((QuerySnapshot event) {
      event.documentChanges.forEach((DocumentChange docChange) {
        if (docChange.type == DocumentChangeType.added) {
          _list.add(PhoenixCMSType.fromMap(
              docChange.document.documentID, docChange.document.data));
        } else {
          int idx = _list.indexWhere((PhoenixCMSType _type) {
            if (_type.id == docChange.document.documentID) {
              return true;
            } else
              return false;
          });
          if (docChange.type == DocumentChangeType.modified) {
            _list[idx] = PhoenixCMSType.fromMap(
                docChange.document.documentID, docChange.document.data);
          } else {
            _list.removeAt(idx);
          }
        }
      });
      return _list;
    });
  }

  Stream<List<PhoenixCMSField>> streamCollectionFields(String id) {
    List<PhoenixCMSField> _list = List<PhoenixCMSField>();
    return firestore
        .collection('phoenixcms_schema')
        .document(id)
        .collection('fields')
        .snapshots()
        .map((QuerySnapshot event) {
      event.documentChanges.forEach((DocumentChange docChange) {
        if (docChange.type == DocumentChangeType.added) {
          _list.add(PhoenixCMSField.fromMap(
              docChange.document.documentID, docChange.document.data, id));
        } else {
          int idx = _list.indexWhere((PhoenixCMSField _field) {
            if (_field.id == docChange.document.documentID) {
              return true;
            } else
              return false;
          });
          if (docChange.type == DocumentChangeType.modified) {
            _list[idx] = PhoenixCMSField.fromMap(
                docChange.document.documentID, docChange.document.data, id);
          } else {
            _list.removeAt(idx);
          }
        }
      });
      return _list;
    });
  }

  Stream<List<PhoenixCMSDocument>> streamCollectionData(String id) {
    List<PhoenixCMSDocument> _list = List<PhoenixCMSDocument>();
    return firestore.collection(id).snapshots().map((QuerySnapshot event) {
      event.documentChanges.forEach((DocumentChange docChange) {
        if (docChange.type == DocumentChangeType.added) {
          _list.add(PhoenixCMSDocument.fromMap(
              id, docChange.document.documentID, docChange.document.data));
        } else {
          int idx = _list.indexWhere((PhoenixCMSDocument _doc) {
            if (_doc.id == docChange.document.documentID) {
              return true;
            } else
              return false;
          });
          if (docChange.type == DocumentChangeType.modified) {
            _list[idx] = PhoenixCMSDocument.fromMap(
                id, docChange.document.documentID, docChange.document.data);
          } else {
            _list.removeAt(idx);
          }
        }
      });
      return _list;
    });
  }

/* 
'List',
'Map',
'Text',
'Bool',
'Number',
'Timestamp',
'Type'
*/

  Future<bool> saveData(
      PhoenixCMSCollection collection,
      String docId,
      Map<String, dynamic> formInputs,
      Map<String, String> fieldTypes,
      Set<String> choices,
      Map<String, DateTime> selectedDates) async {
    formInputs.forEach((String key, dynamic value) {
      String type = fieldTypes[key];
      switch (type) {
        case "text":
          break;
        case "number":
          formInputs[key] = int.tryParse(value);
          break;
        case "bool":
          break;
        case "timestamp":
          formInputs[key] = selectedDates[key];
          break;
        case "type":
          break;
        case "map":
          break;
        case "list":
          formInputs[key] = [value];
          break;
        case "multi":
          formInputs[key] = choices.toList();
          break;
        default:
          break;
      }
    });
    try {
      if (docId == null) {
        await firestore.collection(collection.id).add(formInputs);
      } else {
        await firestore
            .collection(collection.id)
            .document(docId)
            .updateData(formInputs);
      }
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<void> updateTypeFieldValue(
      String collectionId, String typeId, String fieldId, bool value) async {
    if (value) {
      await firestore
          .collection('phoenixcms_schema')
          .document(collectionId)
          .collection('types')
          .document(typeId)
          .updateData({
        'fields': FieldValue.arrayUnion([fieldId])
      });
    } else {
      await firestore
          .collection('phoenixcms_schema')
          .document(collectionId)
          .collection('types')
          .document(typeId)
          .updateData({
        'fields': FieldValue.arrayRemove([fieldId])
      });
    }
  }
}

class PhoenixCMSCollection {
  final String id;
  final String collectionName;
  final String typeDataField;
  final String createLevel;

  PhoenixCMSCollection(
      this.id, this.collectionName, this.typeDataField, this.createLevel);
  factory PhoenixCMSCollection.fromMap(String id, Map data) {
    return PhoenixCMSCollection(
        id, data['name'], data['typeDataField'], data['createLevel']);
  }
}

class PhoenixCMSField {
  final String id;
  final String fieldName;
  final String fieldType;
  final String collectionId;
  final List choices;

  PhoenixCMSField(
      this.id, this.fieldName, this.fieldType, this.collectionId, this.choices);
  factory PhoenixCMSField.fromMap(String id, Map data, String collectionId) {
    List choices;
    if (data['type'] == "multi") {
      choices = data['choices'];
    }
    return PhoenixCMSField(
        id, data['name'], data['type'], collectionId, choices);
  }
}

class PhoenixCMSType {
  final String id;
  final List fields;
  final String name;

  PhoenixCMSType(this.id, this.name, this.fields);
  factory PhoenixCMSType.fromMap(String id, Map data) {
    return PhoenixCMSType(id, data['name'], data['fields']);
  }
}

class PhoenixCMSDocument {
  final String collectionId;
  final String id;
  final Map<String, dynamic> data;

  PhoenixCMSDocument(this.collectionId, this.id, this.data);

  factory PhoenixCMSDocument.fromMap(String collectionId, String id, Map data) {
    return PhoenixCMSDocument(collectionId, id, data);
  }
}
