import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:toast/toast.dart';
import '../model/user.dart';
import '../constants.dart' as Constants;

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  Map data = {};
  TextEditingController amountController = new TextEditingController();
  TextEditingController descController = new TextEditingController();

  List<User> users = [];
  @override
  void initState() {
    List<User> usersList = [];
    FirebaseFirestore.instance
        .collection(Constants.COLLECTION_USER)
        .orderBy('firstName', descending: true)
        .snapshots()
        .listen((snapshot) {
      usersList.clear();
      snapshot.docs.forEach((element) {
        print(element.id);
        usersList.add(User(
            id: element.id,
            firstName: element.get('firstName'),
            lastName: element.get('lastName'),
            username: element.get('username'),
            email: element.get('email')));
        setState(() {
          users = usersList;
        });
      });
    });
    super.initState();
  }

  String type;
  User selectedContact;

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;
    String title = '';
    type = data['type'];
    if (type == 'Payment') {
      title = "Payment";
    } else {
      title = "Cash In";
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Amount',
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: TextField(
                controller: descController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description',
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: Text(
                    'Transaction Date: ${DateFormat.yMMMMd('en_US').add_jm().format(DateTime.now())}')),
            addUserSelectedText(),
            addUserSelection(),
            RaisedButton(
              onPressed: () {
                addTransaction(context);
              },
              child: Text('Submit'),
            )
          ],
        ),
      ),
    );
  }

  Widget addUserSelectedText() {
    if (type == 'Payment') {
      if (selectedContact == null) {
        return Text('');
      } else {
        return Text(selectedContact.toString());
      }
    }
    return Container();
  }

  Widget addUserSelection() {
    if (type == 'Payment') {
      return RaisedButton(
        onPressed: () {
          SelectDialog.showModal<User>(
            context,
            label: "Select Contact",
            items: users.map((e) => e).toList(),
            onChange: (User selected) {
              setState(() {
                selectedContact = selected;
              });
            },
          );
        },
        child: Text('Select Contact'),
      );
    }
    return Container();
  }

  void addTransaction(BuildContext context) async {
    CollectionReference transactions =
        FirebaseFirestore.instance.collection(Constants.COLLECTION_TRANSCTION);

    Map addTransactionMap = {
      'description': descController.text,
      'amount': amountController.text,
      'date': DateFormat.yMMMMd('en_US').format(DateTime.now()),
      'time': DateFormat.jm().format(DateTime.now())
    };

    if (type == 'Payment') {
      addTransactionMap['contactId'] = selectedContact.id;
    }
    transactions
        .add(addTransactionMap)
        .then((value) => {
              Toast.show("Payment Posted", context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM),
              Navigator.pop(context)
            })
        .catchError((error) => {
              Toast.show("An error occured", context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM)
            });
  }
}
