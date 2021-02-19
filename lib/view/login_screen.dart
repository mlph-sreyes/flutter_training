import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart' as Constants;
import 'package:toast/toast.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = new TextEditingController();

  TextEditingController passwordController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Login'),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            RaisedButton(
              onPressed: () {
                login();
              },
              child: Text('Login'),
            ),
            FlatButton(
                onPressed: () {
                  Navigator.pushNamed(context, Constants.ROUTE_REGISTER);
                },
                child: Text('No Account? Sign up'))
          ],
        ),
      ),
    );
  }

  void login() {
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
    FirebaseFirestore.instance
        .collection('user')
        .where('username', isEqualTo: usernameController.text)
        .where('password', isEqualTo: passwordController.text)
        .get()
        .then((value) => {
              Navigator.pop(context),
              if (value.docs.first != null)
                {Navigator.pushNamed(context, Constants.ROUTE_DASHBOARD)}
              else
                {
                  Toast.show("Invalid login credentials", context,
                      duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM)
                }
            })
        .catchError((error) => {
              Toast.show("An error occured", context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM)
            });
  }
}
