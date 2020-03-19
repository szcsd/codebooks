
import 'package:flutter/material.dart';

import 'appglobal.dart';
import 'mainpage.dart';

void main() {
  //debugPaintSizeEnabled = true;
  AppGlobal.init().then((e) {
    runApp(MyApp());
  });
}

