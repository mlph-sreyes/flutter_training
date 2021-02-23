class TransactionData {
  String amount;
  String datetime;
  String desc;
  String userId;
  String type;
  String selectedContactId;
  String selectedContactName;
  TransactionData(
      {this.amount,
      this.datetime,
      this.desc,
      this.userId,
      this.type,
      this.selectedContactId,
      this.selectedContactName});
}
