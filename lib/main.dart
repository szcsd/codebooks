import 'package:codebooks/chcrypt.dart';
import 'package:codebooks/appglobal.dart';
import 'package:codebooks/helppage.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'about.dart';

void main() {
  //debugPaintSizeEnabled = true;
  AppGlobal.init().then((e) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppGlobal.appName,
      supportedLocales: [const Locale('zh')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CodeBookHomePage(),
      routes: {'help': (context) => HelpPage()},
    );
  }
}

class ChatSetting extends StatefulWidget {
  ChatSetting({Key key, @required this.onTranslate}) : super(key: key);
  final ValueChanged<String> onTranslate;
  @override
  ChatSettingState createState() {
    return ChatSettingState();
  }
}

class ChatSettingState extends State<ChatSetting> {
  bool autoPasted = true;
  List<bool> isExpended = [true, false];
  TextEditingController keyController = TextEditingController();
  TextEditingController miController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.0),
            child: ExpansionPanelList(
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  isExpended[index] = !isExpanded;
                });
              },
              children: <ExpansionPanel>[
                ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(title: Text("密钥设置"));
                    },
                    body: Container(
                      margin:
                          EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: keyController,
                              decoration: InputDecoration.collapsed(
                                  hintText: "输入密钥",
                                  border: OutlineInputBorder()),
                            ),
                          ),
                          /*Container(
                            margin: EdgeInsets.only(left: 8.0),
                            child: RaisedButton(
                              color: Colors.blue,
                              highlightColor: Colors.blue[700],
                              colorBrightness: Brightness.dark,
                              splashColor: Colors.grey,
                              child: Text("获取公钥"),
                              onPressed: (){

                              },
                            ),
                          ),*/
                          Switch(
                            value: autoPasted,
                            onChanged: (value) {
                              setState(() {
                                autoPasted = value;
                              });
                            },
                          ),
                          Text("自动粘贴")
                        ],
                      ),
                    ),
                    isExpanded: isExpended[0]),
                ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(title: Text("手工转译密文"));
                    },
                    body: Container(
                      margin:
                          EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              maxLines: null,
                              controller: miController,
                              decoration: InputDecoration.collapsed(
                                  hintText: "他的密文",
                                  border: OutlineInputBorder()),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10.0),
                            child: RaisedButton.icon(
                              icon: Icon(Icons.translate),
                              color: Colors.blue,
                              splashColor: Colors.grey,
                              highlightColor: Colors.blue[700],
                              colorBrightness: Brightness.dark,
                              label: Text("转译"),
                              onPressed: () {
                                widget.onTranslate(miController.text);
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    isExpanded: isExpended[1])
              ],
            )));
  }
}

class ChatMsgContent {
  String fromname;
  String text;
  bool isme = false;

  ChatMsgContent({this.fromname, this.text})
      : isme = fromname == "我" ? true : false; //:fromname = isme? "我": fromname
}

//条目
class ChatMessage extends StatelessWidget {
  ChatMessage({this.msg, this.animationController});
  final ChatMsgContent msg;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    //print(context);
    Offset _tapPosition;
    return new SizeTransition(
        sizeFactor: new CurvedAnimation(
            parent: animationController, curve: Curves.easeOut),
        axisAlignment: 0.0,
        child: new Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: new Row(
            //mainAxisAlignment: msg.isme? MainAxisAlignment.start: MainAxisAlignment.end,
            textDirection: msg.isme ? TextDirection.rtl : TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                //margin: const EdgeInsets.only(right: 16.0),
                child: new CircleAvatar(child: new Text(msg.fromname[0])),
              ),
              new Flexible(
                child: GestureDetector(
                  onTapDown: (TapDownDetails pos) {
                    _tapPosition = pos.globalPosition;
                  },
                  onLongPress: () async {
                    final RenderBox overlay =
                        Overlay.of(context).context.findRenderObject();
                    final value = await showMenu(
                        context: context,
                        position: RelativeRect.fromRect(
                            _tapPosition & Size(40, 40),
                            Offset.zero & overlay.size),
                        items: [
                          PopupMenuItem(child: Text('复制'), value: 'copy'),
                          PopupMenuItem(
                            child: Text('收藏'),
                            value: 'favorite',
                            enabled: false,
                          ),
                        ]);
                    if (value == "copy") {
                      Clipboard.setData(ClipboardData(text: msg.text));
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: msg.isme
                            ? Colors.lightGreenAccent[700]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10.0)),
                    child: new Text(msg.text),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class SendChatText extends StatefulWidget {
  SendChatText({Key key, @required this.onSubmitted}) : super(key: key);

  final ValueChanged<String> onSubmitted;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SendChatTextState();
  }
}

class SendChatTextState extends State<SendChatText> {
  final TextEditingController _textController = new TextEditingController();
  final FocusNode msgNode = FocusNode();

  bool _isComposing = false;
  void _handleOnSubmitted(String text) {
    setState(() {
      _isComposing = false;
    });
    _textController.clear();
    if (text.trim().isEmpty) return;
    print(["send len", text.length]);
    widget.onSubmitted(text);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: Theme.of(context).platform == TargetPlatform.iOS
          ? new BoxDecoration(
              border: new Border(top: new BorderSide(color: Colors.grey[200])))
          : null,
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              maxLines: null,
              focusNode: msgNode,
              textInputAction: TextInputAction.send,
              controller: _textController,
              onChanged: (String text) {
                setState(() {
                  _isComposing = text.length > 0;
                });
              },
              onSubmitted: _handleOnSubmitted,
              decoration: InputDecoration.collapsed(hintText: "输入要加密的消息"),
            ),
          ),
          Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: _isComposing
                    ? () {
                        msgNode.unfocus();
                        _handleOnSubmitted(_textController.text);
                      }
                    : null,
              ))
        ],
      ),
    );
  }
}

class CodeBookHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CodeBookHomePageState();
  }
}

class CodeBookHomePageState extends State<CodeBookHomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final List<ChatMessage> _messages = <ChatMessage>[];
  static GlobalKey<ChatSettingState> _chatsettingKey = GlobalKey();
  BuildContext _buildContext;
  String _cacheMeMessage = "";
  DateTime _lastPressedAt;

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void _addMessage(String fromname, String text) {
    ChatMessage message = new ChatMessage(
      msg: ChatMsgContent(fromname: fromname, text: text),
      animationController: new AnimationController(
        duration: new Duration(milliseconds: 700),
        vsync: this,
      ),
    );
    setState(() {
      _messages.insert(0, message);
    });
    message.animationController.forward();
  }

  void _handleOnSubmitted(String text) {
    _addMessage("我", text);
    _handleCryptMessage(text);
  }

  void _handleOnTranslate(String text) {
    final detext = _deCryptMessage(text);
    //print(["len:", detext.length]);
    if (detext.isNotEmpty) _addMessage("译", detext);
  }

  void _showSnackBar(String text) {
    Scaffold.of(_buildContext).showSnackBar(SnackBar(
      content: Text(text),
      duration: Duration(seconds: 3),
    ));
  }

  bool _handleCryptMessage(String text) {
    final gbkbytes = gbk.encode(text);
    final keytext = _chatsettingKey.currentState.keyController.text;
    if (keytext.isEmpty) {
      _showSnackBar("未设置密钥！");
      return false;
    }
    final enbytes = AesCoder(keytext, AlgType.salsa20).enCrypt(gbkbytes);
    final String cryptText = gbk.decode(BaseGbkEncoder.encode(enbytes));
    Clipboard.setData(ClipboardData(text: cryptText));
    _cacheMeMessage = cryptText;
    _showSnackBar("加密串已经自动复制，请到目标程序粘贴！");
    return true;
  }

  String _deCryptMessage(String text) {
    final gbktext = gbk.encode(text);
    final dst = BaseGbkEncoder.decodeBytes(gbktext);
    if (dst.isEmpty) {
      //print("dst is null");
      _showSnackBar("非密文，忽略！");
      return "";
    }
    final keytext = _chatsettingKey.currentState.keyController.text;
    if (keytext.isEmpty) {
      _showSnackBar("未设置密钥！");
      return "";
    }
    final deval = AesCoder(keytext, AlgType.salsa20).deCrypt(dst);
    final detext = gbk.decode(deval);
    return detext;
  }

  getClipboardContents() async {
    ClipboardData clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text.trim() != '') {
      if (_cacheMeMessage == clipboardData.text) return;
      final detext = _deCryptMessage(clipboardData.text);
      if (detext.isNotEmpty) {
        Clipboard.setData(ClipboardData(text: ''));
        _addMessage("他", detext);
      }
    }
  }

  void _onAppBarSelected(String value) {
    if (value == 'clean') {
      setState(() {
        _messages.clear();
      });
    } else if (value == "about") {
      showAppAboutDialog(_buildContext);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    if (state == AppLifecycleState.resumed &&
        _chatsettingKey.currentState.autoPasted) {
      //print("getClipboardContents");
      Future.delayed(Duration(microseconds: 500),()=>getClipboardContents());
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    for (ChatMessage message in _messages)
      message.animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppGlobal.appName),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.content_paste),
              tooltip: '手工粘贴密文',
              onPressed: () {
                getClipboardContents();
              },
            ),
            IconButton(
              icon: Icon(Icons.live_help),
              tooltip: 'app帮助',
              onPressed: () {
                Navigator.pushNamed(context, 'help');
              },
            ),
            PopupMenuButton<String>(
                onSelected: _onAppBarSelected,
                itemBuilder: (BuildContext context) {
                  return <PopupMenuItem<String>>[
                    PopupMenuItem<String>(
                      value: "clean",
                      child: Text('清空'),
                    ),
                    PopupMenuItem<String>(
                      value: "about",
                      child: Text("关于"),
                    )
                  ];
                })
          ],
        ),
        body: new WillPopScope(
            onWillPop: () async {
              if(_lastPressedAt == null || (DateTime.now().difference(_lastPressedAt) > Duration(seconds: 1))){
                //两次点击间隔超过1秒，重新计时
                _lastPressedAt = DateTime.now();
                return false;
              }
              return true;
            },
            child: Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: Builder(builder: (context) {
                  _buildContext = context;
                  return Column(
                    children: <Widget>[
                      Container(
                        child: ChatSetting(
                            key: _chatsettingKey,
                            onTranslate: _handleOnTranslate),
                      ),
                      Divider(height: 1.0),
                      Flexible(
                          child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: ListView.builder(
                            padding: EdgeInsets.all(8.0),
                            reverse: true,
                            itemBuilder: (BuildContext context, int index) {
                              return _messages[index];
                            },
                            itemCount: _messages.length),
                      )),
                      Divider(height: 1.0),
                      Container(
                        decoration:
                            BoxDecoration(color: Theme.of(context).cardColor),
                        child: SendChatText(
                          onSubmitted: _handleOnSubmitted,
                        ),
                      ),
                    ],
                  );
                }))));
  }
}
