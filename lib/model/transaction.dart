class TransactionData {
  String amount;
  String datetime;
  String desc;
  String senderId;
  String senderName;
  String type;
  String receiverId;
  String selectedContactName;
  TransactionData(
      {this.amount,
      this.datetime,
      this.desc,
      this.senderId,
      this.senderName,
      this.type,
      this.receiverId,
      this.selectedContactName});
}
