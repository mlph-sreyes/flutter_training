import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart' as Constants;
import '../model/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int balance = 0;

  void loadTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<TransactionData> transactionsList = [];
    FirebaseFirestore.instance
        .collection(Constants.COLLECTION_TRANSACTION)
        .where('userId', isEqualTo: prefs.getString(Constants.KEY_USER_ID))
        .orderBy('datetime', descending: true)
        .snapshots()
        .listen((snapshot) {
      balance = 0;
      transactionsList.clear();
      transactions.clear();
      snapshot.docs.forEach((element) {
        int amount = int.parse(element.get('amount'));
        if (element.get('type') == 'Cash In') {
          balance += amount;
        } else {
          balance = balance - amount;
        }
        if (transactionsList.length < 5) {
          if (element.get('type') == 'Payment') {
            transactionsList.add(TransactionData(
                datetime: element.get('datetime'),
                amount: element.get('amount'),
                desc: element.get('description'),
                type: element.get('type'),
                selectedContactId: element.get('selectedContactId'),
                selectedContactName: element.get('selectedContactName')));
          } else {
            transactionsList.add(TransactionData(
                datetime: element.get('datetime'),
                amount: element.get('amount'),
                desc: element.get('description'),
                type: element.get('type')));
          }
        }
      });
      setState(() {
        transactions = transactionsList;
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  void handleClick(String value) {
    switch (value) {
      case 'View All Transactions':
        Navigator.pushNamed(context, Constants.ROUTE_TRANSACTIONS_LIST);
        break;
      case 'View Saved Contact List':
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
    loadTransactions();
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
                                vertical: 15, horizontal: 15),
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
                                vertical: 15, horizontal: 15),
                            child: RaisedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, Constants.ROUTE_TRANSACTION,
                                      arguments: {'type': 'Payment'});
                                },
                                icon: Icon(Icons.payment),
                                label: Text('Pay'))))
                  ],
                ),
                Container(
                    child: Column(
                  children: transactions.map((transaction) {
                    return createTransactionItem(transaction);
                  }).toList(),
                ))
              ],
            ),
          ),
        ));
  }

  Widget createTransactionItem(TransactionData transaction) {
    if (transaction.type == 'Cash In') {
      return drawCashInTransaction(transaction);
    } else {
      return drawPaymentTransaction(transaction);
    }
  }

  Widget drawPaymentTransaction(TransactionData transaction) {
    return Card(
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  height: 50.0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15, 15, 0, 0),
                    child: Text('${transaction.datetime}',
                        style: TextStyle(
                          fontSize: 16.0,
                        )),
                  )),
              SizedBox(
                height: 30.0,
                child: Container(
                    padding: EdgeInsets.fromLTRB(15, 0, 0, 15),
                    child: Text('Paid to ' + transaction.selectedContactName,
                        style: TextStyle(fontSize: 14.0))),
              )
            ],
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                  height: 50.0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(0, 15, 15, 0),
                    child: Text('- Php ${transaction.amount}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.red)),
                  )),
              SizedBox(
                height: 30.0,
                child: Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 15, 15),
                    child: Text(transaction.desc,
                        style: TextStyle(fontSize: 12.0))),
              )
            ],
          ))
        ],
      ),
    );
  }

  Widget drawCashInTransaction(TransactionData transaction) {
    return Card(
      child: Row(
        children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  height: 50.0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15, 15, 0, 0),
                    child: Text('${transaction.datetime}',
                        style: TextStyle(
                          fontSize: 16.0,
                        )),
                  )),
              SizedBox(
                height: 30.0,
                child: Container(
                    padding: EdgeInsets.fromLTRB(15, 0, 0, 15),
                    child: Text(transaction.type,
                        style: TextStyle(
                          fontSize: 14.0,
                        ))),
              )
            ],
          )),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                  height: 50.0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(0, 15, 15, 0),
                    child: Text('+ Php ${transaction.amount}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.green)),
                  )),
              SizedBox(
                height: 30.0,
                child: Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 15, 15),
                    child: Text(transaction.desc,
                        style: TextStyle(fontSize: 12.0))),
              )
            ],
          ))
        ],
      ),
    );
  }
}
