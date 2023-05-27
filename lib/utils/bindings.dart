import 'package:get/get.dart';
import 'package:chatgpt/ui/home/homeVM.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeVM());
  }
}

class CommonBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeVM());
  }
}
