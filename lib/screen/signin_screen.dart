import 'package:L3P1/controller/firebasecontroller.dart';
import 'package:L3P1/model/constant.dart';
import 'package:L3P1/model/photocomment.dart';
import 'package:L3P1/model/photomemo.dart';
import 'package:L3P1/model/profile.dart';
import 'package:L3P1/screen/myview/mydialog.dart';
import 'package:L3P1/screen/signup_screen.dart';
import 'package:L3P1/screen/userhome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = './signInScreen';
  @override
  State<StatefulWidget> createState() {
    return _SignInState();
  }
}

class _SignInState extends State<SignInScreen> {
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
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 15.00),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Text('PhotoMemo',
                      style: TextStyle(fontFamily: 'Satisfy', fontSize: 70.0)),
                ),
                Text(
                  'Sign in, please!',
                  style: TextStyle(fontFamily: 'Satisfy', fontSize: 30.0),
                ),
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
                  obscureText: true,
                  autocorrect: false,
                  validator: con.validatePassword,
                  onSaved: con.savePassword,
                ),
                RaisedButton(
                  onPressed: con.signIn,
                  child: Text(
                    'Sign In',
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                RaisedButton(
                  onPressed: con.signUp,
                  child: Text('Create a new account',
                      style: Theme.of(context).textTheme.button),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _SignInState state;
  _Controller(this.state);
  String email;
  String password;
  String validateEmail(String value) {
    if (value.contains('@') && value.contains('.'))
      return null;
    else
      return 'invalid email address';
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

  void signIn() async {
    if (!state.formKey.currentState.validate()) return;
    state.formKey.currentState.save();

    User user;
    MyDialog.circularProgressStart(state.context);
    try {
      user = await FirebaseController.signIn(email: email, password: password);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context,
        title: 'Sign In Error',
        content: e.toString(),
      );
      return;
    }

    try {
      List<PhotoMemo> photoMemoList =
          await FirebaseController.getPhotoMemoList(email: user.email);
      MyDialog.circularProgressStop(state.context);
      Navigator.pushNamed(state.context, UserHomeScreen.routeName, arguments: {
        Constant.ARG_USER: user,
        Constant.ARG_PHOTOMEMOLIST: photoMemoList,
      });
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
          context: state.context,
          title: 'getPhotoMemoList error',
          content: '$e');
    }
  }

  void signUp() {
    //navigate to sign up screen
    Navigator.pushNamed(state.context, SignUpScreen.routeName);
  }
}
