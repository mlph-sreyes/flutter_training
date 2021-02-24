import 'package:flutter/material.dart';
import 'package:flutter_training/model/saved_contact.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart' as Constants;
import 'package:shared_preferences/shared_preferences.dart';

class SavedContactScreen extends StatefulWidget {
  @override
  _SavedContactScreenState createState() => _SavedContactScreenState();
}

class _SavedContactScreenState extends State<SavedContactScreen> {
  List<SavedContact> savedContacts = [];

  void loadContacts() async {
    List<SavedContact> savedContactsList = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseFirestore.instance
        .collection(Constants.COLLECTION_SELECTED_CONTACT)
        .where('userId', isEqualTo: prefs.getString(Constants.KEY_USER_ID))
        .snapshots()
        .listen((snapshot) {
      savedContactsList.clear();
      savedContacts.clear();
      snapshot.docs.forEach((element) {
        savedContactsList.add(SavedContact(
            userId: element.get('userId'),
            contactFirstName: element.get('contactFirstName'),
            contactLastName: element.get('contactLastName'),
            contactId: element.get('contactId')));
      });
      setState(() {
        savedContacts = savedContactsList;
      });
    });
  }

  @override
  void initState() {
    loadContacts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Transactions List'),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: savedContacts.map((contact) {
                return Card(
                  child: Row(
                    children: [
                      Expanded(
                          child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: Text(
                            '${contact.contactFirstName} ${contact.contactLastName}',
                            style: TextStyle(
                              fontSize: 16.0,
                            )),
                      )),
                      Container(
                          padding: EdgeInsets.fromLTRB(8, 8, 15, 8),
                          child: RaisedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, Constants.ROUTE_TRANSACTION,
                                    arguments: {
                                      'type': 'Payment',
                                      'selectedUserId': contact.contactId,
                                      'selectedUserFirstName':
                                          contact.contactFirstName,
                                      'selectedUserLastName':
                                          contact.contactLastName
                                    });
                              },
                              icon: Icon(Icons.payment),
                              label: Text('Pay')))
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ));
  }
}
