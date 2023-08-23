import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_view_ble/web_view_ble.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flowser",
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
  var url = 'https://framework-ota.netlify.app/';

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
              TextField(
                decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
                controller: urlController,
                keyboardType: TextInputType.url,
                onSubmitted: (value) {
                  var url = Uri.parse(value);
                  if (url.scheme.isEmpty) {
                    url = Uri.parse("https://www.google.com/search?q=" + value);
                  }
                  webViewController?.loadUrl(urlRequest: URLRequest(url: url));
                },
              ),
        ])));
  }
}
