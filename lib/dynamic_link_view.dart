import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DynamicLinkView extends StatefulWidget {
  const DynamicLinkView({Key? key}) : super(key: key);

  @override
  State<DynamicLinkView> createState() => _DynamicLinkViewState();
}

class _DynamicLinkViewState extends State<DynamicLinkView> {
  // Method to handle Background / Foreground State
  void _handleDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData? linkData) async {
        Map<String, dynamic>? queryParameters = linkData?.link.queryParameters;
        if (queryParameters != null) {
          queryParameters.forEach((key, value) {
            debugPrint("Key : $key, Value : $value");
            if (key.contains("curPage")) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NaviagteToPage(
                  pageNo: value,
                ),
              ));
            }
          });
        }
        return linkData;
      },
      onError: (OnLinkErrorException? error) async {
        debugPrint(error!.message.toString());
        return error;
      },
    );
  }

  // Method to handle terminated state
  void _handleTerminatedState() async {
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      final Uri deeplink = initialLink.link;
      Map<String, dynamic>? queryParameters = deeplink.queryParameters;
      queryParameters.forEach((key, value) {
        debugPrint("Key : $key, Value : $value");
        if (key.contains("curPage")) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NaviagteToPage(
              pageNo: value,
            ),
          ));
        }
      });
    }
  }

  @override
  void initState() {
    _handleDynamicLinks();
    _handleTerminatedState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dynamic Links"),
      ),
    );
  }
}

class NaviagteToPage extends StatelessWidget {
  final String? pageNo;
  const NaviagteToPage({Key? key, this.pageNo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Page $pageNo"),
      ),
      body: Center(
        child: Text(" Page $pageNo"),
      ),
    );
  }
}
