import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
          appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(color: Colors.black87),
      )),
      themeMode: ThemeMode.light,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late WebViewController _controller;

  late TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController(text: "https://www.google.com");
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

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('----WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('---Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('---Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''---
                        Page resource error:
                        code: ${error.errorCode}
                        description: ${error.description}
                        errorType: ${error.errorType}
                        isForMainFrame: ${error.isForMainFrame}
                      ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('---blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('---allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            if (change.url != null) {
              setState(() {
                _textEditingController.text = change.url!;
              });
            }

            debugPrint('---url change to ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("--javaScripMessage: " + message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(_textEditingController.text));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 25,
        elevation: 1,
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.home_outlined)),
        title: _textField(),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.add,
              )),
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.layers_rounded,
              )),
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) {
              return [];
            },
          )
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }

  Widget _textField() {
    return TextField(
      controller: _textEditingController,
      maxLines: 1,
      onSubmitted: (value) {
        setState(() {
          _controller.loadRequest(Uri(scheme: "https", host: "youtube"));

          // _controller.loadRequest(Uri.parse(value));
        });
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(left: 10, right: 10),
        border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20)),
        filled: true,
        fillColor: Colors.grey.shade200,
      ),
    );
  }
}
