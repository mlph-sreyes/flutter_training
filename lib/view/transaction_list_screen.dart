import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart' as Constants;
import '../model/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/transaction_card_builder.dart';

class TransactionListScreen extends StatefulWidget {
  @override
  _TransactionListScreenState createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  List<TransactionData> transactions = [];
  String currentUserId = '';

  void loadTransactions() async {
    List<TransactionData> transactionsList = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    transactionsList.clear();
    transactions.clear();
    currentUserId = prefs.getString(Constants.KEY_USER_ID);
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
                return createTransactionItem(transaction, currentUserId);
              }).toList(),
            ),
          ),
        ));
  }
}
