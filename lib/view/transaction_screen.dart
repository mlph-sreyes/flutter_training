import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toast/toast.dart';
import '../constants.dart' as Constants;

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  Map data = {};
  TextEditingController amountController = new TextEditingController();
  TextEditingController descController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;
    String title = '';
    if (data['type'] == 'Payment') {
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

  void addTransaction(BuildContext context) async {
    CollectionReference users =
        FirebaseFirestore.instance.collection(Constants.COLLECTION_TRANSCTION);
    users
        .add({
          'description': descController.text,
          'amount': amountController.text,
          'date': DateFormat.yMMMMd('en_US').format(DateTime.now()),
          'time': DateFormat.jm().format(DateTime.now())
        })
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
