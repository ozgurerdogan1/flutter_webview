import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  WebViewController _controller = WebViewController();
  late bool isSubmitted;

  @override
  void initState() {
    isSubmitted = false;

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..addJavaScriptChannel(
        "Toaster",
        onMessageReceived: (p0) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("java script channel message: ${p0.message}"),
            action: SnackBarAction(
                label: "Ok",
                onPressed: () {
                  Navigator.pop(context);
                }),
          ));
        },
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          print("onNavigationRequest.isMainFrame: ${request.isMainFrame}");

          print("onNavigationRequest.url: ${request.url}");

          return NavigationDecision.navigate;
        },
        onPageStarted: (url) {
          print("onPageStarted: $url");
        },
        onPageFinished: (url) {
          print("onPageFinished: $url");
          if (isSubmitted) {
            _controller.loadRequest(Uri.parse("https://www.facebook.com/"));
            isSubmitted = false;
          }
        },
        onUrlChange: (change) {
          print("onUrlChange: ${change.url}");
        },
        onProgress: (progress) {
          print("onProgress: ${progress}");
        },
        onWebResourceError: (error) {
          print("onWebResourceError.description: ${error.description}");
          print("onWebResourceError.errorCode: ${error.errorCode}");
          print("onWebResourceError.errorType: ${error.errorType}");
          print("onWebResourceError.isForMainFrame: ${error.isForMainFrame}");
        },
      ))
      ..loadRequest(Uri.parse("https://amazon.com"));

    _controller = controller;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebView Example',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WebView Example'),
          actions: [
            IconButton(onPressed: () => _controller.reload(), icon: const Icon(Icons.replay_outlined)),
          ],
        ),
        body: WebViewWidget(controller: _controller),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () async {
                final email = "erdgn54@gmail.com";
                final password = "Ec78cf84";

                _controller.runJavaScript("document.getElementById('m_login_email').value='$email'");
                _controller.runJavaScript("document.getElementById('m_login_password').value='$password'");
                await Future.delayed(Duration(seconds: 1));
                await _controller.runJavaScript("document.forms[1].submit()");
                setState(() {
                  isSubmitted = true;
                });
              },
              child: const Icon(Icons.login_rounded),
            ),
            SizedBox(width: 10),
            FloatingActionButton(
              onPressed: () async {
                final url = await _controller.currentUrl();
                if (url?.contains("www.amazon.com") ?? false) {
                  final res = await _controller
                      .runJavaScriptReturningResult("document.getElementsByTagName('header')[0].style.display='none'");
                  print("javaScriptReturn result: $res");

                  _controller.runJavaScript("document.getElementsByTagName('footer')[0].style.display='none'");
                }
              },
              child: const Icon(Icons.fiber_dvr_sharp),
            ),
            SizedBox(width: 10),
            FloatingActionButton(
              onPressed: () async {
                _controller.loadRequest(
                    Uri.parse("https://m.facebook.com/login/?wtsid=rdr_0kCZO15Eu1EGwwV9k&refsrc=deprecated&_rdr"));
              },
              child: const Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
    );
  }
}
