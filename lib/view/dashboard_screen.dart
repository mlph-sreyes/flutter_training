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
        .orderBy('date', descending: true)
        .limit(5)
        .snapshots()
        .listen((snapshot) {
      transactionsList.clear();
      transactions.clear();
      snapshot.docs.forEach((element) {
        int amount = int.parse(element.get('amount'));
        print(balance);
        if (element.get('type') == 'Cash In') {
          balance += amount;
        } else {
          balance = balance - amount;
        }
        transactionsList.add(TransactionData(
            date: element.get('date'),
            time: element.get('time'),
            amount: element.get('amount'),
            desc: element.get('description')));
        setState(() {
          transactions = transactionsList;
        });
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
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        child: RaisedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, Constants.ROUTE_TRANSACTION,
                                  arguments: {'type': 'Cash In'});
                            },
                            icon: Icon(Icons.add),
                            label: Text('Cash In'))),
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        child: RaisedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, Constants.ROUTE_TRANSACTION,
                                  arguments: {'type': 'Payment'});
                            },
                            icon: Icon(Icons.payment),
                            label: Text('Pay')))
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
    return Card(
      child: Row(
        children: [
          Column(
            children: [
              SizedBox(
                  height: 50.0,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: Expanded(
                        child: Text(transaction.date,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ))),
                  )),
              SizedBox(
                height: 50.0,
                child: Expanded(child: Text(transaction.time)),
              )
            ],
          ),
          Column(
            children: [
              SizedBox(
                  height: 50.0,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: Expanded(
                        child: Text('Php ${transaction.amount}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ))),
                  )),
              SizedBox(
                height: 50.0,
                child: Expanded(child: Text(transaction.desc)),
              )
            ],
          ),
        ],
      ),
    );
  }
}
