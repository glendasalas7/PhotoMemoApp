import 'package:L3P1/controller/firebasecontroller.dart';
import 'package:L3P1/model/profile.dart';
import 'package:L3P1/screen/myview/mydialog.dart';
import 'package:L3P1/screen/signin_screen.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signUpScreen';
  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUpScreen> {
  _Controller con;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Create an account'),
        ),
        body: Padding(
          padding: const EdgeInsets.only(
            top: 15.0,
            left: 15.0,
            right: 15.0,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text('Create an account',
                      style: Theme.of(context).textTheme.headline5),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    validator: con.validateEmail,
                    onSaved: con.saveEmail,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Password',
                    ),
                    autocorrect: false,
                    obscureText: true,
                    validator: con.validatePassword,
                    onSaved: con.savePassword,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Password Confirm',
                    ),
                    autocorrect: false,
                    obscureText: true,
                    validator: con.validatePassword,
                    onSaved: con.savePasswordConfirm,
                  ),
                  con.passwordErrorMessage == null
                      ? SizedBox(height: 1.0)
                      : Text(
                          con.passwordErrorMessage,
                          style: TextStyle(
                              color: Colors.redAccent, fontSize: 14.0),
                        ),
                  RaisedButton(
                    onPressed: con.createAccount,
                    child: Text(
                      'Create',
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class _Controller {
  _SignUpState state;
  _Controller(this.state);
  String email;
  String password;
  String passwordConfirm;
  String passwordErrorMessage;
  Profile tempProfile = Profile();

  void createAccount() async {
    if (!state.formKey.currentState.validate()) return;
    state.render(() => passwordErrorMessage = null);
    state.formKey.currentState.save();

    if (password != passwordConfirm) {
      state.render(() => passwordErrorMessage = 'passwords do not match!');
      return;
    }

    tempProfile.signUpDate = DateTime.now();
    tempProfile.name = "";
    tempProfile.email = email;
    tempProfile.description = "";

    try {
      await FirebaseController.createAccount(email: email, password: password);
      await FirebaseController.createProfile(tempProfile);
      Navigator.pushNamed(state.context, SignInScreen.routeName);
      MyDialog.info(
          context: state.context,
          title: 'Account Created! ',
          content: 'Go to Sign In to use the app!');
    } catch (e) {
      MyDialog.info(
          context: state.context, title: 'Cannot Create', content: '$e');
    }
  }

  String validateEmail(String value) {
    if (value.contains('@') && value.contains('.'))
      return null;
    else
      return 'invalid email';
  }

  void saveEmail(String value) {
    email = value;
  }

  String validatePassword(String value) {
    if (value.length < 6)
      return 'too short';
    else
      return null;
  }

  void savePassword(String value) {
    password = value;
  }

  void savePasswordConfirm(String value) {
    passwordConfirm = value;
  }
}
