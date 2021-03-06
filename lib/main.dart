import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_firebase_samples/cloud_messaging_view.dart';
import 'package:flutter_firebase_samples/dynamic_link_view.dart';
import 'package:flutter_firebase_samples/remote_config_view.dart';
import 'package:flutter_firebase_samples/user_auth_email_password.dart';
import 'package:flutter_firebase_samples/user_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(title: 'Flutter Firebase'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return const UserView();
                      },
                    ));
                  },
                  child: const Text("Users")),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return const UserAuthEmailPasswordView();
                      },
                    ));
                  },
                  child: const Text("Authentication")),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return const CloudMessagingView();
                      },
                    ));
                  },
                  child: const Text("Cloud Messaging")),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return const RemoteConfigView();
                      },
                    ));
                  },
                  child: const Text("Remote Config")),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return const DynamicLinkView();
                      },
                    ));
                  },
                  child: const Text("Dynamic Links")),
            )
          ],
        ),
      ),
    );
  }
}
