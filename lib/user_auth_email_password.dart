import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserAuthEmailPasswordView extends StatefulWidget {
  const UserAuthEmailPasswordView({Key? key}) : super(key: key);

  @override
  State<UserAuthEmailPasswordView> createState() =>
      _UserAuthEmailPasswordViewState();
}

class _UserAuthEmailPasswordViewState extends State<UserAuthEmailPasswordView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passWordController = TextEditingController();

  final ValueNotifier<bool> _isSignIn = ValueNotifier<bool>(false);

  void _changeSignIn() {
    _isSignIn.value = !_isSignIn.value;
  }

  Future<void> _logInWithEmailPassword(
      {required BuildContext context,
      required String email,
      required String password}) async {
    try {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        // ignore: avoid_print
        print(value.user!.email);
        return value;
      });
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print(e);
      _showSnackBar(context: context, message: e.message.toString());
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<void> _createAccountWithEmailPassword(
      {required BuildContext context,
      required String email,
      required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print(e);
      _showSnackBar(context: context, message: e.message.toString());
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void _showSnackBar({required BuildContext context, required String message}) {
    final SnackBar snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passWordController.dispose();
    _isSignIn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder<User?>(
                stream: _auth.authStateChanges(),
                builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Padding(
                    padding: const EdgeInsets.all(15),
                    child: snapshot.data == null
                        ? const Text("Currently logged into : None")
                        : Text(
                            "Currently logged into : ${snapshot.data!.email}"),
                  );
                }),
            Container(
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(5)),
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    hintText: "Email",
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                )),
            Container(
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(5)),
                child: TextFormField(
                  controller: _passWordController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    hintText: "Password",
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Align(
                  alignment: Alignment.centerRight,
                  child: ValueListenableBuilder<bool>(
                      valueListenable: _isSignIn,
                      builder: (context, value, child) {
                        return TextButton(
                            onPressed: _changeSignIn,
                            child: value
                                ? const Text("Click to login to current user!")
                                : const Text("Click to create new user!"));
                      })),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ValueListenableBuilder<bool>(
                  valueListenable: _isSignIn,
                  builder: (context, value, child) {
                    return ElevatedButton(
                        onPressed: value
                            ? () async {
                                if (_emailController.text.isEmpty ||
                                    _passWordController.text.isEmpty) {
                                  _showSnackBar(
                                      context: context,
                                      message:
                                          "Email & Password cannot be empty!");
                                } else {
                                  await _createAccountWithEmailPassword(
                                          context: context,
                                          email: _emailController.text,
                                          password: _passWordController.text)
                                      .then((value) {
                                    _emailController.clear();
                                    _passWordController.clear();
                                  });
                                }
                              }
                            : () async {
                                if (_emailController.text.isEmpty ||
                                    _passWordController.text.isEmpty) {
                                  _showSnackBar(
                                      context: context,
                                      message:
                                          "Email & Password cannot be empty!");
                                } else {
                                  await _logInWithEmailPassword(
                                          context: context,
                                          email: _emailController.text,
                                          password: _passWordController.text)
                                      .then((value) {
                                    _emailController.clear();
                                    _passWordController.clear();
                                  });
                                }
                              },
                        child: value
                            ? const Text("Sign In")
                            : const Text("Log In"));
                  }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ElevatedButton(
                  onPressed: () async => await _signOut(),
                  child: const Text("Signout")),
            )
          ],
        ),
      ),
    );
  }
}
