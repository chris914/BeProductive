import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_timemanagement/api/API.dart';
import 'package:flutter_timemanagement/data/user.dart' as UserModel;
import 'package:flutter_timemanagement/util/authentication_notifier.dart';
import 'package:flutter_timemanagement/util/user_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../styles.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController =
      TextEditingController(text: "your-account@gmail.com");
  TextEditingController passwordController =
      TextEditingController(text: "yourpassword");
  bool showContent = true;

  //#region InitState + Build

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.userChanges().listen((User? user) {
      if (UserManager.initialized) return;

      UserManager.initialized = true;
      if (user != null) {
        showContent = false;
        _showProgressbar(context);
        context.read<AuthenticationNotifier>().changeIsAuthenticated(true);
        UserManager.uid = user.uid;
        _hideProgressbar(context);
      } else
        showContent = true;

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
            decoration: BoxDecoration(gradient: loginScreenGradient),
            child: showContent == false
                ? Container()
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/logo.png'),
                        Container(
                          width: 280,
                          child: TextField(
                              style: lightRegularText,
                              controller: emailController,
                              decoration: InputDecoration(
                                  hintText: "E-mail",
                                  hintStyle: hintRegularText,
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: Icon(Icons.email_outlined,
                                        size: 20, color: Colors.white30),
                                  ),
                                  isDense: true,
                                  prefixIconConstraints: BoxConstraints.expand(
                                      width: 26, height: 26),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.blueGrey)))),
                        ),
                        SizedBox(height: 15),
                        Container(
                          width: 280,
                          child: TextField(
                              style: lightRegularText,
                              controller: passwordController,
                              obscureText: true,
                              obscuringCharacter: '*',
                              decoration: InputDecoration(
                                  hintText: "Password",
                                  hintStyle: hintRegularText,
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: Icon(Icons.lock_outline,
                                        size: 20, color: Colors.white30),
                                  ),
                                  isDense: true,
                                  prefixIconConstraints: BoxConstraints.expand(
                                      width: 26, height: 26),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.blueGrey)))),
                        ),
                        SizedBox(height: 25),
                        _buildSignInButtonWidget(context),
                        Container(
                          child: SignInButton(
                            Buttons.GoogleDark,
                            padding: EdgeInsets.only(right: 60),
                            elevation: 4.0,
                            onPressed: () {
                              _signInWithGoogle(context);
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        _buildSignUpWidget(context),
                      ],
                    ),
                  )));
  }

  //#endregion

  //#region Widgets

  Widget _buildSignInButtonWidget(BuildContext context) {
    return Container(
      width: 280,
      child: ElevatedButton(
        child: Container(
          width: double.infinity,
          decoration: new BoxDecoration(
              gradient: new LinearGradient(
            colors: [
              Colors.deepPurple,
              Color.fromRGBO(198, 78, 79, 1),
            ],
          )),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
          child: Text(
            "LOG IN",
            textAlign: TextAlign.center,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0.0),
          elevation: 4,
        ),
        onPressed: () {
          _signInEmailPassword(
              context, emailController.text, passwordController.text);
        },
      ),
    );
  }

  Widget _buildSignUpWidget(BuildContext context) {
    return Container(
      width: 280,
      child: Row(
        children: [
          Text("No account yet?", style: TextStyle(color: Colors.white60)),
          Padding(
              padding: EdgeInsets.only(left: 4),
              child: InkWell(
                  onTap: () {
                    _registerEmailPasswordDialog(context);
                  },
                  child: Text("Sign up with email",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  //#endregion

  //#region Helpers

  /// Starts the Google Account signing method.
  /// If authentication is successful user will be navigated to the next page.
  void _signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount googleUser = (await GoogleSignIn().signIn())!;
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    var result = await FirebaseAuth.instance.signInWithCredential(credential);
    if (result.user != null) {
      var uid = result.user!.uid;
      var name = result.user!.displayName ?? "";
      var user = UserModel.User(uid, "Google", name, "", 0, false, 0, 1, []);

      var doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.documentId)
          .get();
      if (!doc.exists) {
        FirebaseFirestore.instance
            .collection("users")
            .doc(user.documentId)
            .set(user.toJson());
        API.logEvent("register_google_account");
      }

      context.read<AuthenticationNotifier>().changeIsAuthenticated(true);
      UserManager.uid = uid;
    }
  }

  /// Starts the Email + Password signing method.
  /// If authentication is successful user will be navigated to the next page.
  void _signInEmailPassword(
      BuildContext context, String email, String password) async {
    if (email == "" || password == "") return;

    bool isSigningIn = true;
    try {
      ApiHelper.safeCallNetworkMethod(() async {
        _showProgressbar(context); // progress dialog
        var uid = await API.signInEmailPassword(email, password);
        print(uid);
        context.read<AuthenticationNotifier>().changeIsAuthenticated(true);
        UserManager.uid = uid;
        _hideProgressbar(context);
        isSigningIn = false;
      }, errorCallback: () {
        var snackBar = SnackBar(
            content: Text(
                'The application encountered connection issues. Please fix them and re-try.'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } on AuthException catch (e) {
      if (e.code == 'user-not-found') {
        if (isSigningIn) _hideProgressbar(context);

        _showFailureRegisterDialog(context, 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        if (isSigningIn) _hideProgressbar(context);

        _showFailureRegisterDialog(
            context, 'Wrong password provided for that user.');
      } else
        _hideProgressbar(context);
    }
  }

  /// Shows a general-purpose error dialog.
  void _showFailureRegisterDialog(BuildContext context, String errorMsg) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
                title: Text("Error"),
                content: Text(errorMsg),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: Text("OK"),
                  )
                ]),
        barrierDismissible: true);
  }

  /// Hides the progressbar.
  void _hideProgressbar(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Shows a progressbar on top of the current content.
  void _showProgressbar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(),
                  ),
                ],
              ),
              backgroundColor: Colors.transparent,
            ),
        barrierDismissible: false);
  }

  /// Registers a new user with Email + Password.
  /// Uses F-base authentication to do this, also adds a new user model to the F-store.
  /// Later: Use Cloud Functions for this?
  void _registerEmailPasswordDialog(BuildContext context) async {
    TextEditingController email = TextEditingController(text: "");
    TextEditingController password = TextEditingController(text: "");
    TextEditingController name = TextEditingController(text: "");

    showDialog(
        context: context,
        builder: (context) {
          String? errorText;
          return StatefulBuilder(builder: (context, setState2) {
            return AlertDialog(
                title: Text("Register your account",
                    style: GoogleFonts.robotoCondensed()),
                content: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 280,
                        child: TextField(
                            style: TextStyle(color: Colors.black),
                            controller: name,
                            decoration: InputDecoration(
                                hintText: "Display Name",
                                hintStyle: TextStyle(color: Colors.blueGrey),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: Icon(Icons.person,
                                      size: 20, color: Colors.black),
                                ),
                                isDense: true,
                                prefixIconConstraints: BoxConstraints.expand(
                                    width: 26, height: 26),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.blueGrey)))),
                      ),
                      Container(
                        width: 280,
                        child: TextField(
                            style: TextStyle(color: Colors.black),
                            controller: email,
                            decoration: InputDecoration(
                                hintText: "Email",
                                hintStyle: TextStyle(color: Colors.blueGrey),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: Icon(Icons.email_outlined,
                                      size: 20, color: Colors.black),
                                ),
                                isDense: true,
                                prefixIconConstraints: BoxConstraints.expand(
                                    width: 26, height: 26),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.blueGrey)))),
                      ),
                      Container(
                        width: 280,
                        child: TextField(
                            style: TextStyle(color: Colors.black),
                            controller: password,
                            obscureText: true,
                            obscuringCharacter: '*',
                            decoration: InputDecoration(
                                hintText: "Password",
                                hintStyle: TextStyle(color: Colors.blueGrey),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: Icon(Icons.lock_outline,
                                      size: 20, color: Colors.black),
                                ),
                                isDense: true,
                                prefixIconConstraints: BoxConstraints.expand(
                                    width: 26, height: 26),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.blueGrey)))),
                      ),
                      Visibility(
                          visible: errorText != null && errorText!.length > 0,
                          child: Text(errorText != null ? errorText! : "",
                              style: GoogleFonts.roboto(color: Colors.red))),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      var eText = await _registerEmailPassword(
                          name.text, email.text, password.text);
                      setState2(() {
                        errorText = eText;
                      });
                      if (errorText ==
                          null) // Registration completed, no error came back
                        Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: Text("Register"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: Text("Cancel"),
                  )
                ]);
          });
        },
        barrierDismissible: false);
  }

  Future<String?> _registerEmailPassword(
      String name, String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      var uid = userCredential.user!.uid;
      var user = UserModel.User(
          uid, "EmailPW", name, "", 0, false, 0, 1, []); // change this

      FirebaseFirestore.instance
          .collection("users")
          .doc(user.documentId)
          .set(user.toJson());
    } on FirebaseAuthException catch (e) {
      print(e);
      if (e.code == 'weak-password') {
        return "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        return "This e-mail address is already in use.";
      }
    } catch (e) {
      print(e);
    }

    return null;
  }

//#endregion
}
