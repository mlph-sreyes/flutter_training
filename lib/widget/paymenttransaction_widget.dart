import 'package:flutter/material.dart';
import '../model/transaction.dart';

class PaymentTransactionWidget extends StatelessWidget {
  final TransactionData transaction;
  final bool isReceiver;

  const PaymentTransactionWidget({this.transaction, this.isReceiver}) : super();

  @override
  Widget build(BuildContext context) {
    Text amountText;
    String paymentInfo = '';
    if (isReceiver) {
      amountText = Text('+ Php ${transaction.amount}',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              color: Colors.green));
      paymentInfo = 'Received from ' + transaction.senderName;
    } else {
      amountText = Text('- Php ${transaction.amount}',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.red));
      paymentInfo = 'Paid to ' + transaction.selectedContactName;
    }
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
                    child: Text(paymentInfo, style: TextStyle(fontSize: 14.0))),
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
                    child: amountText,
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
