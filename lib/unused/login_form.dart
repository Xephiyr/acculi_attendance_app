/*
import 'package:flutter/material.dart';
import 'package:randomtest/sign_in.dart';

var emailController = TextEditingController();
var passwordController = TextEditingController();

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @overridecd
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    email = ModalRoute.of(context).settings.arguments;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Lyfas On-Ground Support'),
        ),
        key: _scaffoldKey,
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Enter your Email ID ',
                      labelText: 'E-Mail',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(90)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (email) {
                      if (email.isEmpty) {
                        return 'Date cannot be empty';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your Password',
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    obscuringCharacter: '*',
                    validator: (password) {
                      if (password.isEmpty) {
                        return 'Password cannot be empty';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 100, right: 100, bottom: 10),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: RaisedButton(
                        child: const Text('Submit'),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            // If the form is valid, display a Snackbar.
                            String password, email;
                            password = passwordController.text;
                            email = emailController.text;
                            String val;
                            val = await signInEmail(email, password);

                            if (val != null) {
                              _scaffoldKey.currentState
                                  .showSnackBar(SnackBar(content: Text('Data is in processing.')));
                              await new Future.delayed(new Duration(seconds: 4));

                              emailController.clear();
                              passwordController.clear();
                              Navigator.pushReplacementNamed(context, '/attendancePanel');
                            }
                          }
                        }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/
