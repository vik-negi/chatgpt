import 'package:get/get.dart';
import 'package:chatgpt/main.dart';
import 'package:chatgpt/ui/home/home.dart';
import 'package:chatgpt/utils/bindings.dart';

class AppRoutes {
  static const navigation = '/';
  static const home = '/home';

  static final pages = [
    GetPage(
      name: home,
      page: () => HomePage(),
      binding: HomeBinding(),
    ),
  ];
}
