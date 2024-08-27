import 'package:flutter_webview/mainPageController.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyNavigationDelegate {
  MyNavigationDelegate._();
  static MyNavigationDelegate? _instance;
  static MyNavigationDelegate get instance {
    return _instance ??= MyNavigationDelegate._();
  }

  get get => NavigationDelegate(
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
          /* if (isSubmitted) {
            _controller.loadRequest(Uri.parse("https://www.facebook.com/"));
            isSubmitted = false;
          } */
        },
        onUrlChange: (change) {
          print("onUrlChange: ${change.url}");
          MainPageController.instance.addUrlData(change.url);
        },
        onProgress: (progress) {
          MainPageController.instance.addProgressData(progress.toDouble());
          print("onProgress: ${progress}");
        },
        onWebResourceError: (error) {
          print("onWebResourceError.description: ${error.description}");
          print("onWebResourceError.errorCode: ${error.errorCode}");
          print("onWebResourceError.errorType: ${error.errorType}");
          print("onWebResourceError.isForMainFrame: ${error.isForMainFrame}");
        },
      );
}
