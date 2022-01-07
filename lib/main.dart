import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
String value_text_isbn = "";
String value_text_location = "";

class InfoOne {
  final String session;
  final String url_text;

  InfoOne({
    required this.session,
    required this.url_text,
  });

  factory InfoOne.fromJson(Map<String, dynamic> json) {
    return InfoOne(
      session: json['session'],
      url_text: json['books'][value_text_isbn][value_text_location]['reserveurl'],//このように目的のところまで[]をつなげる
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey_name = GlobalKey<FormState>();
  final _formKey_isbn = GlobalKey<FormState>();
  final _formKey_location = GlobalKey<FormState>();
  String API_KEY = "ac8bea11c70423bc1a3b4b8fde42e19d";
  String value_text_name = "";
  Future<void>? _launched;
  late Future<InfoOne> futureAlbum;

  //ブラウザで開く
  Future<void> _launchInBrowser(String url) async {
    if (!await launch(
      url,
      forceSafariVC: false,
      forceWebView: false,
      headers: <String, String>{'my_header_key': 'my_header_value'},
    )) {
      throw 'Could not launch $url';
    }
  }

  Future<InfoOne> fetchAlbum() async {
    final response = await http
        .get(Uri.parse('https://api.calil.jp/check?appkey=$API_KEY&isbn=$value_text_isbn&systemid=$value_text_location&format=json&callback=no'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print("Success");
      var res_url=InfoOne.fromJson(jsonDecode(response.body));
      print(res_url.url_text);
      _launchInBrowser(res_url.url_text);
      return InfoOne.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print("Out");
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
        resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        reverse: true,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomSpace),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 50,),
                Text('図書館在庫確認アプリ',
                  style: GoogleFonts.mochiyPopOne(
                      fontSize: 30
                  ),
                ),
                SizedBox(height: 20,),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset('images/tosyokan_book_tana.png'),
                ),
                SizedBox(height: 20,),
                Text("Step①書籍のISBN(コード)を検索",
                  style: TextStyle(
                      fontSize: 20
                  )),
                SizedBox(height: 20,),
            Row(//「何年？」と「何月？」を隣に
              mainAxisAlignment: MainAxisAlignment.center,
              children:<Widget>[
                Form(
                  key: _formKey_name,
                  child: SizedBox(//書籍名入力フォーム
                    width: 250,
                    child:TextFormField(
                      style: TextStyle(fontSize: 15),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        hintText: '書籍名を入力してください',
                        labelText: '書籍名を入力してください',
                      ),
                      validator: (value) {//ボタンを押した時の判断で返ってくる
                        if (value!.isEmpty) {
                          return '必須です。';
                        }
                        return null;
                      },
                      onChanged: (String? value){
                        setState(() {
                          value_text_name = value.toString();
                        });
                        print(value.toString());
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  // SizedBoxで囲んでwidth/heightをつける
                  width: 70,
                  height: 50,
                  child:ElevatedButton(
                    onPressed: () => setState(() {
                      _launched = _launchInBrowser("http://www.google.co.jp/search?hl=ja&source=hp&q=$value_text_name+ +ISBN");
                    }),
                    child: Text(
                      "ISBN検索",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.deepOrange, //ボタンの背景色
                      onPrimary: Colors.black,//押したときの色
                    ),
                  ),
                ),
              ],
              ),
                SizedBox(height: 40,),
                Text("Step②ISBNと地名を入力",
                    style: TextStyle(
                        fontSize: 20
                    )),
                SizedBox(height: 20,),
                Form(
                  key: _formKey_isbn,
                  child: SizedBox(//ISBN入力フォーム
                    width: 300,
                    child:TextFormField(
                      style: TextStyle(fontSize: 15),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        hintText: 'ISBNを入力してください(半角数字)',
                        labelText: 'ISBNを入力してください(半角数字)',
                      ),
                      validator: (value) {//ボタンを押した時の判断で返ってくる
                        if (value!.isEmpty) {
                          return '必須です。';
                        }
                        return null;
                      },
                      onChanged: (String? value){
                        setState(() {
                          value_text_isbn = value.toString();
                        });
                        print("value_isbn  "+value.toString());
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Form(
                  key: _formKey_location,
                  child: SizedBox(//ISBN入力フォーム
                    width: 300,
                    child:TextFormField(
                      style: TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        hintText: '都道府県_都市名のローマ字半角',
                        labelText: '都道府県_都市名のローマ字半角(例：Hyogo_Kobe)',
                      ),
                      validator: (value) {//ボタンを押した時の判断で返ってくる
                        if (value!.isEmpty) {
                          return '必須です。';
                        }
                        return null;
                      },
                      onChanged: (String? value){
                        setState(() {
                          value_text_location = value.toString();
                        });
                        print("value_location  "+value.toString());
                      },
                    ),
                  ),
                ),
                SizedBox(height: 50,),
                SizedBox(
                  // SizedBoxで囲んでwidth/heightをつける
                  width: 130,
                  height: 50,
                  child:ElevatedButton(
                    onPressed:(){
                      fetchAlbum();
                    },
                    child: Text(
                      "検索",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.pinkAccent, //ボタンの背景色
                      onPrimary: Colors.black,//押したときの色
                    ),
                  ),
                ),
              ]
            ),
     // This trailing comma makes auto-formatting nicer for build methods.
    ),
        ),
      ));
  }
}
