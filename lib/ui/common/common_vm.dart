import 'package:get/get.dart';

class CommonVM extends GetxController {
  final index = 0.obs;
  void changeIndex(int index) {
    this.index.value = index;
  }
}
