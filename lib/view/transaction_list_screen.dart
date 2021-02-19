import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart' as Constants;
import '../model/transaction.dart';

class TransactionListScreen extends StatefulWidget {
  @override
  _TransactionListScreenState createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  List<TransactionData> transactions = [];

  @override
  void initState() {
    List<TransactionData> transactionsList = [];
    FirebaseFirestore.instance
        .collection(Constants.COLLECTION_TRANSCTION)
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      transactionsList.clear();
      transactions.clear();
      snapshot.docs.forEach((element) {
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Transactions List'),
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            child: Container(
                child: Column(
              children: transactions.map((transaction) {
                return createTransactionItem(transaction);
              }).toList(),
            )),
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
