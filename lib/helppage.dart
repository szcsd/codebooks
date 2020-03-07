import 'package:codebooks/appglobal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'about.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(AppGlobal.appName + "帮助"),
      ),
      body: SingleChildScrollView(
        child: Container(
        margin: EdgeInsets.all(16.0),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.black,
              height: 1.5
            ),
            children: <TextSpan>[
              TextSpan(
                style: themeData.textTheme.headline6,
                text: "一、初衷\n",
              ),
              TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  height: 1.8,
                  fontWeight: FontWeight.w700,
                  color: Colors.red[900]
                ),
                text: "        解决重要私密信息在即时聊天工具中被偷窥、窃取的可能。\n",
              ),
              TextSpan(
                style: themeData.textTheme.headline6,
                text: "二、使用方法\n",
              ),
              TextSpan(
                style: themeData.textTheme.bodyText1,
                text: "1. 通过短信或其它聊天工具告知接收方密钥。\n"
                      "2. 发送方在本APP中设置好密钥，输入要发送的信息，APP会自动转译为密文并已自动复制，到聊天工具中粘贴发送即可。\n"
                      "3. 接收方在本APP中设置好密钥，当收到密文后，复制密文切换至密码本APP（就如淘宝粘贴口令操作一样）。\n"
                      "4. 本APP里面显示解密后真正的信息。\n",
              ),
              TextSpan(
                style: themeData.textTheme.headline6,
                text: "三、其它问题\n",
              ),
              TextSpan(
                style: themeData.textTheme.bodyText1,
                text: "1. 密钥就是明文转换为密文或将密文转换为明文的算法中输入的钥匙。\n"
                      "2. 为免除用户安全方面的担心，本app没有申请联网权限，纯本地使用的app。\n"
                      "3. app采用先进的加密算法，只要不泄露密钥，基本无破解可能，详情可见开放源码。\n"
                      "4. 有任何开发意见可以至开源仓库的Issues提交，如访问不了，建议修改本地DNS为:8.8.8.8试试。\n",
              ),
              LinkTextSpan(
                style: themeData.textTheme.bodyText2.copyWith(color: themeData.accentColor),
                url: 'https://github.com/szcsd/codebooks',
                text: '[加密电报]开源仓库',
              ),
            ]
          ),
        ),
      ),
    ));
  }
}
