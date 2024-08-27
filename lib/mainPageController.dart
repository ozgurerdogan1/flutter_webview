import 'dart:async';

class MainPageController {
  MainPageController._();

  static MainPageController? _instance;
  static MainPageController get instance {
    return _instance ??= MainPageController._();
  }

  final StreamController<String> urlController = StreamController<String>();
  late Stream<String> urlStream;

  final StreamController<double> progressController = StreamController<double>();
  late Stream<double> progressStream;

  init() {
    urlStream = urlController.stream;
    progressStream = progressController.stream;
  }

  addUrlData(String? data) {
    urlController.add(data ?? "null");
  }

  addProgressData(double? data) {
    print("addProgressData: $data");
    progressController.add(data ?? 0);
  }
}
