import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:toast/toast.dart';
import '../model/user.dart';
import '../model/transaction.dart';
import '../constants.dart' as Constants;
import 'package:shared_preferences/shared_preferences.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  Map data = {};
  TextEditingController amountController = new TextEditingController();
  TextEditingController descController = new TextEditingController();

  List<User> users = [];

  int balance = 0;
  String currentUserId = '';
  String curretnUserName = '';

  void loadTransactions() async {
    List<TransactionData> transactionsList = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    transactionsList.clear();
    currentUserId = prefs.getString(Constants.KEY_USER_ID);
    curretnUserName = prefs.getString(Constants.KEY_USER_NAME);
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
    });
  }

  String userId = '';
  void loadUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString(Constants.KEY_USER_ID);
    List<User> usersList = [];
    FirebaseFirestore.instance
        .collection(Constants.COLLECTION_USER)
        .orderBy('firstName', descending: true)
        .snapshots()
        .listen((snapshot) {
      usersList.clear();
      snapshot.docs.forEach((element) {
        if (element.id != userId) {
          usersList.add(User(
              id: element.id,
              firstName: element.get('firstName'),
              lastName: element.get('lastName'),
              username: element.get('username'),
              email: element.get('email')));
        }
      });
      setState(() {
        users = usersList;
      });
    });
  }

  @override
  void initState() {
    loadUsers();
    loadTransactions();
    super.initState();
  }

  String transactionType = '';
  User selectedContact;

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;
    String title = '';
    transactionType = data['type'].toString();
    if (data['selectedUserId'] != null) {
      selectedContact = User(
          id: data['selectedUserId'],
          firstName: data['selectedUserFirstName'],
          lastName: data['selectedUserLastName']);
    }
    if (transactionType == 'Payment') {
      title = "Payment";
    } else {
      title = "Cash In";
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Amount',
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: TextField(
                controller: descController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description',
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: Text(
                    'Transaction Date: ${DateFormat.yMMMMd('en_US').add_jm().format(DateTime.now())}')),
            addUserSelectedText(),
            addUserSelection(),
            addSaveContactCheckBox(),
            RaisedButton(
              onPressed: () {
                addTransaction(context);
              },
              child: Text('Submit'),
            )
          ],
        ),
      ),
    );
  }

  Widget addUserSelectedText() {
    if (transactionType == 'Payment') {
      if (selectedContact == null) {
        return Text('');
      } else {
        return Text(selectedContact.toString());
      }
    }
    return Container();
  }

  bool saveUser = false;
  Widget addSaveContactCheckBox() {
    if (transactionType == 'Payment') {
      return Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Checkbox(
              value: saveUser,
              onChanged: (bool newValue) {
                setState(() {
                  saveUser = newValue;
                });
              }),
          Text('Save Contact')
        ],
      ));
    } else {
      return Container();
    }
  }

  Widget addUserSelection() {
    if (transactionType == 'Payment') {
      return RaisedButton(
        onPressed: () {
          SelectDialog.showModal<User>(
            context,
            label: "Select Contact",
            items: users.map((e) => e).toList(),
            onChange: (User selected) {
              setState(() {
                selectedContact = selected;
              });
            },
          );
        },
        child: Text('Select Contact'),
      );
    }
    return Container();
  }

  void addTransaction(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    CollectionReference transactions =
        FirebaseFirestore.instance.collection(Constants.COLLECTION_TRANSACTION);
    if (balance < int.parse(amountController.text) &&
        transactionType == 'Payment') {
      Toast.show("Insufficient Funds", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: new CircularProgressIndicator()),
                Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: new Text("Loading")),
              ],
            ),
          );
        },
      );
      Map<String, String> addTransactionMap = {
        'description': descController.text,
        'amount': amountController.text,
        'datetime': DateFormat.MMMd('en_US').format(DateTime.now()) +
            ' ' +
            DateFormat.jm().format(DateTime.now()),
        'type': transactionType,
      };
      if (transactionType == 'Payment') {
        addTransactionMap['receiverId'] = selectedContact.id;
        addTransactionMap['senderId'] = prefs.getString(Constants.KEY_USER_ID);
        addTransactionMap['senderName'] = curretnUserName;
        addTransactionMap['selectedContactName'] =
            selectedContact.firstName + " " + selectedContact.lastName;
      } else {
        addTransactionMap['receiverId'] =
            prefs.getString(Constants.KEY_USER_ID);
      }
      transactions
          .add(addTransactionMap)
          .then((value) => {
                if (transactionType == 'Payment')
                  {
                    FirebaseFirestore.instance
                        .collection(Constants.COLLECTION_SELECTED_CONTACT)
                        .where('userId', isEqualTo: userId)
                        .where('contactId', isEqualTo: selectedContact.id)
                        .get()
                        .then((value) => {
                              if (value.docs.first.exists)
                                {
                                  Navigator.pop(context),
                                  Toast.show("Payment Posted", context,
                                      duration: Toast.LENGTH_SHORT,
                                      gravity: Toast.BOTTOM),
                                  Navigator.pop(context),
                                }
                              else
                                {
                                  createSavedContact(),
                                },
                            })
                        .catchError((error) => {
                              print('create saved contact error'),
                              createSavedContact(),
                            }),
                  }
                else
                  {
                    Navigator.pop(context),
                    Toast.show("Payment Posted", context,
                        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM),
                    Navigator.pop(context),
                  }
              })
          .catchError((error) => {
                Toast.show("An error occured", context,
                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM)
              });
    }
  }

  void createSavedContact() {
    print('create saved contact');
    Map<String, String> addSavedUserMap = {};
    addSavedUserMap['userId'] = userId;
    addSavedUserMap['contactFirstName'] = selectedContact.firstName;
    addSavedUserMap['contactLastName'] = selectedContact.lastName;
    addSavedUserMap['contactId'] = selectedContact.id;
    FirebaseFirestore.instance
        .collection(Constants.COLLECTION_SELECTED_CONTACT)
        .add(addSavedUserMap)
        .then((value) => {
              Navigator.pop(context),
              Toast.show("Payment Posted", context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM),
              Navigator.pop(context),
            })
        .catchError((error) => {
              print('$error'),
              Toast.show("An error occured", context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM)
            });
  }
}
