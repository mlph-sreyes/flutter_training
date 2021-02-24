import 'package:flutter/material.dart';
import '../model/transaction.dart';
import '../widget/cashintransaction_widget.dart';
import '../widget/paymenttransaction_widget.dart';

Widget createTransactionItem(
    TransactionData transaction, String currentUserId) {
  if (transaction.type == 'Cash In') {
    return CashInTransactionWidget(
      transaction: transaction,
    );
  } else {
    if (transaction.receiverId == currentUserId) {
      return PaymentTransactionWidget(
          transaction: transaction, isReceiver: true);
    } else {
      return PaymentTransactionWidget(
          transaction: transaction, isReceiver: false);
    }
  }
}
