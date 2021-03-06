import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart' as Constants;
import '../model/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/transaction_card_builder.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int balance = 0;
  String currentUserId = '';
  String currentUserFName = '';
  String currentUserLName = '';

  void loadTransactions() async {
    List<TransactionData> transactionsList = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    transactionsList.clear();
    transactions.clear();
    currentUserId = prefs.getString(Constants.KEY_USER_ID);
    currentUserFName = prefs.getString(Constants.KEY_USER_FNAME);
    currentUserLName = prefs.getString(Constants.KEY_USER_LNAME);
    FirebaseFirestore.instance
        .collection(Constants.COLLECTION_TRANSACTION)
        .where('senderId', isEqualTo: currentUserId)
        .orderBy('datetime', descending: true)
        .snapshots()
        .listen((snapshot) {
      snapshot.docs.forEach((element) {
        if (element.get('type') == 'Payment') {
          transactionsList.add(TransactionData(
              datetime: element.get('datetime'),
              amount: element.get('amount'),
              desc: element.get('description'),
              type: element.get('type'),
              receiverId: element.get('receiverId'),
              selectedContactName: element.get('selectedContactName')));
        } else {
          transactionsList.add(TransactionData(
              datetime: element.get('datetime'),
              amount: element.get('amount'),
              desc: element.get('description'),
              type: element.get('type'),
              receiverId: element.get('receiverId')));
        }
        balance -= int.parse(element.get('amount'));
      });
      setState(() {
        transactionsList.sort((a, b) => a.datetime.compareTo(b.datetime));
        transactions = transactionsList;
      });
    });
    FirebaseFirestore.instance
        .collection(Constants.COLLECTION_TRANSACTION)
        .where('receiverId', isEqualTo: prefs.getString(Constants.KEY_USER_ID))
        .orderBy('datetime', descending: true)
        .snapshots()
        .listen((snapshot) {
      snapshot.docs.forEach((element) {
        if (element.get('type') == 'Payment') {
          transactionsList.add(TransactionData(
              datetime: element.get('datetime'),
              amount: element.get('amount'),
              desc: element.get('description'),
              type: element.get('type'),
              receiverId: element.get('receiverId'),
              senderName: element.get('senderName'),
              selectedContactName: element.get('selectedContactName')));
        } else {
          transactionsList.add(TransactionData(
              datetime: element.get('datetime'),
              amount: element.get('amount'),
              desc: element.get('description'),
              type: element.get('type'),
              receiverId: element.get('receiverId')));
        }
        balance += int.parse(element.get('amount'));
      });
      setState(() {
        transactionsList.sort((a, b) => a.datetime.compareTo(b.datetime));
        transactions = transactionsList;
      });
    });
  }

  @override
  void initState() {
    loadTransactions();
    super.initState();
  }

  void handleClick(String value) {
    switch (value) {
      case 'View All Transactions':
        Navigator.pushNamed(context, Constants.ROUTE_TRANSACTIONS_LIST);
        break;
      case 'View Saved Contact List':
        Navigator.pushNamed(context, Constants.ROUTE_CONTACT_LIST);
        break;
      case 'Logout':
        clearPrefs();
        Navigator.pop(context);
        break;
    }
  }

  void clearPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Constants.KEY_USER_ID, '');
    prefs.setBool(Constants.KEY_IS_LOGGED_IN, false);
  }

  List<TransactionData> transactions = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: handleClick,
              itemBuilder: (BuildContext context) {
                return {
                  'View All Transactions',
                  'View Saved Contact List',
                  'Logout'
                }.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            child: Column(
              children: [
                Text('Balance: Php $balance',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22.0,
                    )),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 10),
                            child: RaisedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, Constants.ROUTE_TRANSACTION,
                                      arguments: {'type': 'Cash In'});
                                },
                                icon: Icon(Icons.add),
                                label: Text('Cash In')))),
                    Expanded(
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 10),
                            child: RaisedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, Constants.ROUTE_TRANSACTION,
                                      arguments: {'type': 'Payment'});
                                },
                                icon: Icon(Icons.payment),
                                label: Text('Pay')))),
                  ],
                ),
                Row(children: [
                  Expanded(
                      child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                          child: RaisedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, Constants.ROUTE_QR_VIEW,
                                    arguments: {
                                      'currentUserId': currentUserId,
                                      'currentUserFName': currentUserFName,
                                      'currentUserLName': currentUserLName
                                    });
                              },
                              icon: Icon(Icons.arrow_downward),
                              label: Text('Receive')))),
                  Expanded(
                      child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                          child: RaisedButton.icon(
                              onPressed: () {
                                showScanner();
                              },
                              icon: Icon(Icons.arrow_upward),
                              label: Text('Send')))),
                ]),
                Container(
                    child: Column(
                  children: transactions.map((transaction) {
                    return createTransactionItem(transaction, currentUserId);
                  }).toList(),
                ))
              ],
            ),
          ),
        ));
  }

  void showScanner() async {
    if (await Permission.camera.request().isGranted) {
      String cameraScanResult = await scanner.scan();

      List<String> values = cameraScanResult.split(':');
      Navigator.pushNamed(context, Constants.ROUTE_TRANSACTION, arguments: {
        'type': 'Payment',
        'selectedUserId': values[0],
        'selectedUserFirstName': values[1],
        'selectedUserLastName': values[2]
      });
    } else {
      Map<Permission, PermissionStatus> status =
          await [Permission.camera].request();
    }
  }
}
