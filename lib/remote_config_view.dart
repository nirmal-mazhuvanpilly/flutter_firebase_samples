import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigView extends StatefulWidget {
  const RemoteConfigView({Key? key}) : super(key: key);

  @override
  State<RemoteConfigView> createState() => _RemoteConfigViewState();
}

class _RemoteConfigViewState extends State<RemoteConfigView> {
  final RemoteConfig _remoteConfig = RemoteConfig.instance;
  late bool _updated;
  bool _isColor = true;
  String _textValue = "";
  bool _isLoading = false;

  void setConfig() async {
    _remoteConfig.setDefaults(<String, dynamic>{
      'isColor': true,
      'testing_remote_key': "Yellow",
    });

    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(seconds: 10),
    ));

    _updated = await _remoteConfig.fetchAndActivate();
    if (_updated) {
      setState(() {
        _isColor = _remoteConfig.getBool("isColor");
        debugPrint(_isColor.toString());
        _textValue = _remoteConfig.getString("testing_remote_key");
        debugPrint(_textValue);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isColor = _remoteConfig.getBool("isColor");
        debugPrint(_isColor.toString());
        _textValue = _remoteConfig.getString("testing_remote_key");
        debugPrint(_textValue);
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    setConfig();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Remote Config View"),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    child: Text(
                      _textValue,
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: _isColor ? Colors.red : Colors.grey),
                        onPressed: () {},
                        child: const Text("Cloud Messaging")),
                  ),
                ],
              ),
      ),
    );
  }
}
