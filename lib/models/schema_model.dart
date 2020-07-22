import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recase/recase.dart';

final Firestore firestore = Firestore.instance;

class SchemaModel extends ChangeNotifier {
  List<PhoenixCMSCollection> collectionList = List<PhoenixCMSCollection>();

  String fieldName;
  String firestoreFieldName;

  Future<bool> addCollection(
      String collectionName, String firestoreName) async {
    try {
      String _firestoreName = firestoreName;
      if (firestoreName == null || firestoreName.trim() == '') {
        _firestoreName = collectionName.snakeCase;
      }
      await firestore
          .collection('phoenixcms_schema')
          .document(_firestoreName)
          .setData({'name': collectionName});
      collectionList.add(PhoenixCMSCollection(_firestoreName, collectionName));
      notifyListeners();
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> addField(String collectionId, String fieldType) async {
    try {
      String _firestoreFieldName = firestoreFieldName;
      if (firestoreFieldName == null || firestoreFieldName.trim() == '') {
        _firestoreFieldName = fieldName.camelCase;
      }
      Map<String, dynamic> fieldData = {'type': fieldType, 'name': fieldName};
      if (fieldType == "list") {
        fieldData['itemType'] = "text";
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
      collectionList
          .add(PhoenixCMSCollection(snap.documentID, snap.data['name']));
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

  Future<bool> saveData(String collectionId, String docId,
      Map<String, dynamic> formInputs, Map<String, String> fieldTypes) async {
    formInputs.forEach((String key, dynamic value) {
      String type = fieldTypes[key];
      switch (type) {
        case "text":
          break;
        case "number":
          formInputs[key] = int.tryParse(value);
          break;
        case "bool":
          formInputs[key] = value.toString().toLowerCase() == "true";
          break;
        case "timestamp":
          break;
        case "type":
          break;
        case "map":
          break;
        case "list":
          formInputs[key] = [value];
          break;
        default:
          break;
      }
    });
    try {
      if (docId == null) {
        await firestore.collection(collectionId).add(formInputs);
      } else {
        await firestore
            .collection(collectionId)
            .document(docId)
            .updateData(formInputs);
      }
      return true;
    } catch (err) {
      return false;
    }
  }
}

class PhoenixCMSCollection {
  final String id;
  final String collectionName;
  // final List<PhoenixCMSField> fields;

  PhoenixCMSCollection(this.id, this.collectionName);
  factory PhoenixCMSCollection.fromMap(String id, Map data) {
    return PhoenixCMSCollection(id, data['name']);
  }
}

class PhoenixCMSField {
  final String id;
  final String fieldName;
  final String fieldType;
  final String collectionId;

  PhoenixCMSField(this.id, this.fieldName, this.fieldType, this.collectionId);
  factory PhoenixCMSField.fromMap(String id, Map data, String collectionId) {
    return PhoenixCMSField(id, data['name'], data['type'], collectionId);
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
