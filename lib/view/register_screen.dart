import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toast/toast.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool success = false;
  TextEditingController usernameController = new TextEditingController();

  TextEditingController passwordController = new TextEditingController();
  TextEditingController retypePasswordController = new TextEditingController();

  TextEditingController firstNameController = new TextEditingController();

  TextEditingController lastNameController = new TextEditingController();

  TextEditingController emailController = new TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool validatePasswordStructure(String value) {
    String pattern = r'^(?=.*?[a-zA-Z])(?=.*?[0-9]).{6,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  bool validateEmailStructure(String value) {
    String pattern =
        r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  registrationTextFormField(
                      'Username', usernameController, false, (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  }),
                  registrationTextFormField(
                      'Password', passwordController, true, (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    } else if (value.toString().length < 6) {
                      return 'Password must be at least 6 characters';
                    } else if (validatePasswordStructure(value.toString()) ==
                        false) {
                      return 'Password must contain numbers and letters';
                    } else if (value.toString() !=
                        retypePasswordController.text)
                      return 'Password must match';
                    return null;
                  }),
                  registrationTextFormField(
                      'Retype Password', retypePasswordController, true,
                      (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    } else if (value.toString().length < 6) {
                      return 'Password must be at least 6 characters';
                    } else if (validatePasswordStructure(value.toString()) ==
                        false) {
                      return 'Password must contain numbers and letters';
                    } else if (value.toString() != passwordController.text)
                      return 'Password must match';
                    return null;
                  }),
                  registrationTextFormField(
                      'First Name', firstNameController, false, (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  }),
                  registrationTextFormField(
                      'Last Name', lastNameController, false, (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  }),
                  registrationTextFormField('Email', emailController, false,
                      (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    } else if (validateEmailStructure(value.toString()) ==
                        false) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  }),
                  RaisedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        addUser(context);
                      }
                    },
                    child: Text('Submit'),
                  )
                ],
              )),
        ),
      ),
    );
  }

  Widget registrationTextFormField(String label,
      TextEditingController controller, bool isPassword, Function validator) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: TextFormField(
        validator: validator,
        obscureText: isPassword,
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }

  void addUser(BuildContext context) async {
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
    CollectionReference users = FirebaseFirestore.instance.collection('user');
    users
        .add({
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'password': passwordController.text,
          'username': usernameController.text,
          'email': emailController.text
        })
        .then((value) => {
              Navigator.pop(context),
              Toast.show("User Registered", context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM),
              Navigator.pop(context)
            })
        .catchError((error) => {
              Toast.show("An error occured", context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM)
            });
  }
}
