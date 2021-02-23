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
        .collection(Constants.COLLECTION_TRANSACTION)
        .orderBy('datetime', descending: true)
        .snapshots()
        .listen((snapshot) {
      transactionsList.clear();
      transactions.clear();
      snapshot.docs.forEach((element) {
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
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            child: Column(
              children: transactions.map((transaction) {
                return createTransactionItem(transaction);
              }).toList(),
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
