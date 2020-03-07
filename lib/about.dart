
import 'package:codebooks/appglobal.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;

class LinkTextSpan extends TextSpan {

  // Beware!
  //
  // This class is only safe because the TapGestureRecognizer is not
  // given a deadline and therefore never allocates any resources.
  //
  // In any other situation -- setting a deadline, using any of the less trivial
  // recognizers, etc -- you would have to manage the gesture recognizer's
  // lifetime and call dispose() when the TextSpan was no longer being rendered.
  //
  // Since TextSpan itself is @immutable, this means that you would have to
  // manage the recognizer from outside the TextSpan, e.g. in the State of a
  // stateful widget that then hands the recognizer to the TextSpan.

  LinkTextSpan({ TextStyle style, String url, String text }) : super(
      style: style,
      text: text ?? url,
      recognizer: TapGestureRecognizer()..onTap = () {
        launch(url, forceSafariVC: false);
      }
  );
}

void showAppAboutDialog(BuildContext context) {
  final ThemeData themeData = Theme.of(context);
  final TextStyle aboutTextStyle = themeData.textTheme.bodyText2;
  final TextStyle linkStyle = themeData.textTheme.bodyText2.copyWith(color: themeData.accentColor);

  showAboutDialog(
    context: context,
    applicationName: AppGlobal.appName,
    applicationVersion: AppGlobal.version,
    applicationIcon: Icon(Icons.message),
    applicationLegalese: '© 2020 freecoder',
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                style: aboutTextStyle,
                text: '解决在即时聊天软件或短信上重要私密信息传输中被偷窥、窃取的可能。\n'
                    '支持的操作系统：\n'
                    '${defaultTargetPlatform == TargetPlatform.iOS ? 'multiple platforms' : 'iOS and Android'} '
              ),
              TextSpan(
                style: aboutTextStyle,
                text: '.\n\n查看开放源码，请访问:',
              ),
              LinkTextSpan(
                style: linkStyle,
                url: 'https://github.com/szcsd/codebooks',
                text: '\ncodebooks开源仓库',
              ),
              TextSpan(
                style: aboutTextStyle,
                text: '.',
              ),
            ],
          ),
        ),
      ),
    ],
  );
}