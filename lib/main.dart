import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_view_ble/web_view_ble.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Lumaflex_ota",
      home: WebsiteView(),
    ),
  );
}

class WebsiteView extends StatefulWidget {
  const WebsiteView({Key? key}) : super(key: key);

  @override
  State<WebsiteView> createState() => _WebsiteViewState();
}

class _WebsiteViewState extends State<WebsiteView> {
  var url = 'https://framework-ota.vercel.app/';
  // var url = 'https://jeroen1602.github.io/flutter_web_bluetooth/#/';

  final urlController = TextEditingController();
  InAppWebViewController? webViewController;
  bool canGoBack = false;

  @override
  void initState() {
    askBlePermission();
    super.initState();
  }

  askBlePermission() async {
    var blePermission = await Permission.bluetooth.status;
    if (blePermission.isDenied) {
      Permission.bluetooth.request();
    }
    // Android Vr > 12 required These Ble Permission
    if (Platform.isAndroid) {
      var bleConnectPermission = await Permission.bluetoothConnect.status;
      var bleScanPermission = await Permission.bluetoothScan.status;
      if (bleConnectPermission.isDenied) {
        Permission.bluetoothConnect.request();
      }
      if (bleScanPermission.isDenied) {
        Permission.bluetoothScan.request();
      }
    }
  }

  onLoadStop(controller, context) async {
    url = url.toString();
    urlController.text = this.url;
    WebViewBle.init(controller: controller, context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Lumaflex_ota"),
          centerTitle: true,
          leading: canGoBack
              ? IconButton(
                  onPressed: () {
                    webViewController?.goBack();
                  },
                  icon: Icon(Icons.arrow_back_ios))
              : const SizedBox(),
        ),
        body: SafeArea(
            child: Column(children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(url: Uri.parse(url)),
                  onLoadStop: (cntrl, url) async {
                    onLoadStop(cntrl, context);
                    webViewController = cntrl;
                    bool _canGoBack = await cntrl.canGoBack();
                    setState(() {
                      canGoBack = _canGoBack;
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    logSuccess(
                        "ConsoleMessage : ${consoleMessage.messageLevel.toString()} :  ${consoleMessage.message} ");
                  },
                ),
              ],
            ),
          ),
        ])));
  }
}
