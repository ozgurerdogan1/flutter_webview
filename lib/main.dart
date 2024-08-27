import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_webview/mainPageController.dart';
import 'package:flutter_webview/navigationDelegate.dart';
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
  bool headerVisibilty = true;

  @override
  void initState() {
    isSubmitted = false;
    MainPageController.instance.init();

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
      ..setNavigationDelegate(MyNavigationDelegate.instance.get)
      ..loadRequest(Uri.parse("https://globalogretmen.com/"));

    _controller = controller;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebView Example',
      home: Scaffold(
        //appBar: _appBar(),
        //  drawer: _drawer(context),
        body: Column(
          children: [
            /*  StreamBuilder<double>(
                stream: MainPageController.instance.progressStream,
                builder: (context, snapshot) {
                  print("snapshot.progressData: ${snapshot.data}");
                  return snapshot.data == 100
                      ? const SizedBox.shrink()
                      : LinearProgressIndicator(
                          value: (snapshot.data ?? 0) / 100,
                          color: Colors.pink,
                        );
                }), */
            Builder(builder: (context) {
              //print("scroll: ${_controller.getScrollPosition()}");
              _controller.getScrollPosition().then(
                (value) {
                  print("scroll value: $value");
                },
              );

              return Container(
                height: 60,
                decoration: BoxDecoration(color: Colors.black),
              );
            }),
            Expanded(child: WebViewWidget(controller: _controller)),
          ],
        ),
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: ExpandableFab(
          distance: 60,
          type: ExpandableFabType.up,
          pos: ExpandableFabPos.right,
          children: [
            FloatingActionButton.extended(
                onPressed: () {
                  _controller.scrollTo(0, 0);
                  setState(() {});
                },
                label: Text("scrollBy 0,0")),
            FloatingActionButton.extended(
                onPressed: () {
                  _controller.scrollTo(0, 0);
                  setState(() {});
                },
                label: Text("scrollTo 0,0")),
            FloatingActionButton.extended(
                onPressed: () {
                  _controller.loadRequest(Uri.parse("https://www.google.com"));
                },
                label: Text("google")),
            FloatingActionButton.extended(
                onPressed: () async {
                  print("getUserAcent: ${await _controller.getUserAgent()}");
                },
                label: Text("getUserAcent")),
            FloatingActionButton.extended(
                onPressed: () async {
                  print("getTitle: ${await _controller.getTitle()}");
                },
                label: Text("getTitle")),
            FloatingActionButton.extended(
                onPressed: () {
                  _controller.enableZoom(true);
                },
                label: Text("zoom")),

            /*   FloatingActionButton(
              onPressed: () async {
                final email = "erdgn54@gmail.com";
                final password = "Ec78cf84";

                _controller
                    .runJavaScript("document.getElementById('m_login_email').value='$email'");
                _controller
                    .runJavaScript("document.getElementById('m_login_password').value='$password'");
                await Future.delayed(Duration(seconds: 1));
                await _controller.runJavaScript("document.forms[1].submit()");
                setState(() {
                  isSubmitted = true;
                });
              },
              child: const Icon(Icons.login_rounded),
            ), */
            SizedBox(width: 10),
            FloatingActionButton(
              onPressed: () async {
                final url = await _controller.currentUrl();
                dynamic res;

                if (headerVisibilty == true) {
                  if (url?.contains("globalogretmen.com/") ?? false) {
                    res = await _controller.runJavaScriptReturningResult(
                        "document.getElementsByTagName('header')[0].style.display='none'");
                    print("javaScriptReturn result: $res");

                    _controller.runJavaScript(
                        "document.getElementsByTagName('footer')[0].style.display='none'");
                  }
                }

                if (headerVisibilty == false) {
                  res = await _controller.runJavaScriptReturningResult(
                      "document.getElementsByTagName('header')[0].style.display=''");
                  print("javaScriptReturn result: $res");

                  _controller
                      .runJavaScript("document.getElementsByTagName('footer')[0].style.display=''");
                }

                headerVisibilty = !headerVisibilty;
              },
              child: const Icon(Icons.fiber_dvr_sharp),
            ),
            SizedBox(width: 10),
            FloatingActionButton(
              onPressed: () {
                _controller.loadRequest(Uri.parse(
                    "https://m.facebook.com/login/?wtsid=rdr_0kCZO15Eu1EGwwV9k&refsrc=deprecated&_rdr"));
              },
              child: const Icon(Icons.facebook),
            ),
          ],
        ),
      ),
    );
  }

  Drawer _drawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'MENU',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Ana Sayfa'),
            onTap: () {
              // Perform some action
              Navigator.of(context).pop(); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Paylaş'),
            onTap: () {
              // Perform some action
              Navigator.of(context).pop(); // Close the drawer
            },
          ),
        ],
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: null,
      actions: [
        IconButton(onPressed: () => _controller.reload(), icon: const Icon(Icons.replay_outlined)),
      ],
      //leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
    );
  }

  IconButton _arrowBackButton() {
    return IconButton(
        onPressed: () {
          print("dsfe");
          /*   print("scrollPosition: ${await _controller.getScrollPosition()}");
            _controller.goBack();
            if (!(await _controller.canGoBack())) {} */
        },
        icon: const Icon(Icons.arrow_back_ios_new));
  }

  StreamBuilder<String> _streamTitle() {
    return StreamBuilder<String>(
        stream: MainPageController.instance.urlStream,
        builder: (context, snapshot) {
          return Text(snapshot.data.toString());
        });
  }
}
