

import 'dart:io';

class AppGlobal {
  static String appName = "加密电报";
  static String version = '1.0.1';

  static Future init() async {
    //初始化信息，如读取配置
    print(Platform.operatingSystem);
  }
}