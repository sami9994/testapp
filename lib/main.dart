import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:testapp/contacts.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  systemNavigationBarColor: Colors.lightBlueAccent,
  statusBarColor: Colors.transparent
));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      debugShowCheckedModeBanner: false,
     theme: ThemeData(

       primarySwatch: Colors.grey,
      ),
      home: MyHomePage(),

    );
  }
}
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  String  username ='';
  String password='';
  String  apiRes='';
  String result='';
  String code ='';
  bool val1=false;
  Color color =Colors.lightBlueAccent;

   Future<bool> sendReq(user,pass) async{
     bool val=false;
    var res= await http.get(Uri.parse('https://turkeysms.com.tr/api/v3/user_login/login.php?'
        'username=${user}&password=${pass}&response_type=json'));
    var _result ;
    if (res.statusCode == 200) {
      _result=jsonDecode(res.body);
      print(res.statusCode);
      print(jsonDecode(res.body));
      print(_result['result'].runtimeType);
      print(_result['result_code']);
       result=_result['result'];
      if(_result['result']=='true'){
        val=true;
      }else{
        val=false;
      }
      print(val);
      if(result=='true') {
         apiRes = _result['api_key'];
         code=_result['result'];
         print(apiRes);
       }
      }else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load contacts');
    }
    return val;
  }
  DateTime time = DateTime.now();
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
      final difference = DateTime.now().difference(time);
      final isExitWarning = difference >= Duration(seconds: 2);
      time = DateTime.now();
      if(isExitWarning){
        final message = 'please press again to exit';
        Fluttertoast.showToast(msg: message ,fontSize: 18);
        return false;

      }else{
           return true;
      }
      },
      child: Scaffold(
          appBar: AppBar(
        backgroundColor: color,
        title: Text("TEST APP",style: TextStyle(color: Colors.white),), ),
        body:  Center(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Container (
                      width: 300 ,
                      child: TextField (
                        style: TextStyle (
                          color: color,
                        ),
                        decoration: InputDecoration (
                          hintText: 'User Name' ,
                          hintStyle: TextStyle (
                              color: color, fontSize: 15.0
                          ) ,
                          prefixIcon: Icon (
                            Icons.account_circle_outlined, color: color ,
                            size: 25, ) ,
                        ) ,
                        onChanged: (value) {
                              username =value.trim();
                        },
                      ),
                    ), SizedBox(height: 20),
                    Container (
                      width: 300 ,
                      child: TextField (

                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        style: TextStyle (
                          color: color,
                        ) ,
                        decoration: InputDecoration (
                          hintText: 'Password' ,
                          hintStyle: TextStyle (
                            color: color , fontSize: 15.0,

                          ) ,
                          prefixIcon: Icon (
                            Icons.label_important_outline_sharp, color: color ,
                            size: 25, ) ,
                        ) ,
                        onChanged: (value) {
                          password =value.trim();
                        } ,
                      ) ,
                    ),
                  ],
                ),
                Container(

                  width: 100,
                  child: Container(
                    decoration: BoxDecoration(
                        color: color,borderRadius: BorderRadius.circular(50)

                    ),
                    child: TextButton(onPressed:  () async{

                        if((password!='') && (username!='')){
                          val1=await sendReq(username,password);

                         if(val1==true) {

                           Navigator.push (
                             context ,
                             MaterialPageRoute (
                                 builder: (context) => Contacts ( apiRes ) ) ,
                           );

                         }
                         //TS-1024
                         else{
                           showDialog<String>(
                             context: context,
                             builder: (BuildContext context) =>
                                 AlertDialog(
                                   title:  Text('Try Again',style: TextStyle(color: Colors.red)),
                                   content:  Text('check your password or username!!!',style: TextStyle(color: Colors.black),),
                                   actions: <Widget>[
                                     TextButton(
                                       onPressed: () => Navigator.pop(context, 'Cancel'),
                                       child: const Text('Ok',style: TextStyle(),),
                                     ),

                                   ],
                                 ),


                           );

                         }

                        }


                    },
                      child: Text('Send',style:TextStyle(color:Colors.white))
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

      ),
    );
     // This trailing comma makes auto-formatting nicer for build methods.

  }
}
