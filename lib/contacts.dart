import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class Contacts extends StatefulWidget {
   String api='';
  Contacts(this.api);
  @override
  _ContactsState createState() => _ContactsState();
}
class NameNumber {
  String _api;
  String name;
  String number;
  bool isChecked =false;
  NameNumber(this.name, this.number,this._api);
  factory NameNumber.fromJson(Map<String, dynamic> json) =>NameNumber(json['name'],json['number'],json['_api'],);
  Map<String, dynamic>  toJson() => {
     'api_key':_api,
    'user_name'   :name,
    'user_mobile'   : number,
   };
}
class _ContactsState extends State<Contacts> {
  List<Contact> _contacts =[];
  var numbersData =<dynamic>[];
  var namesData =<dynamic>[];
  List<String> listNumbers=[];
  List<String> listNames=[];
  List<NameNumber> nameNumber=[];
  List<NameNumber> checkedList=[];

  var selectedNames =0;
  bool checkVal=false;
  void checkPermission() async{
    if ( await Permission.contacts.request().isDenied ) {
      exit(0);
    }
  }
  void getContact()async{
    List<Contact> contacts= (await ContactsService.getContacts()).toList();
    setState(() {
      _contacts = contacts;
    });
    setState((){
      for(var i = 0 ; i<_contacts.length ; i++) {
        numbersData.add(_contacts[i].phones!.elementAt(0).value!.replaceAll(' ', ''));
      }

      for(var i = 0 ; i<_contacts.length ; i++) {
        namesData.add(_contacts[i].displayName );
      }
    });
    listNumbers= List<String>.from(numbersData );
    listNames= List<String>.from(namesData);
    setState(() {
      for(var i = 0 ; i<contacts.length ; i++) {
        nameNumber.add(NameNumber(listNames[i], listNumbers[i],widget.api));
      }
    });
  }
  void sendData(arr) async{
          try {
          for(var i =0 ; i<arr.length ; i++){
            await post(Uri.parse('https://turkeysms.com.tr/api/v3/yeni_kisiler_ekleme/add-content'),body: jsonEncode(arr[i]));
          }
        }catch(e){
            print(e);
            throw Exception('Failed to upload name');
        }
  }
  void normalState(){
    for(var i =0; i<nameNumber.length;i++){
      if(nameNumber[i].isChecked==true){
        nameNumber[i].isChecked=false;
      }
      Navigator.pop(context, 'Cancel');
  }}
  void initState(){
    super.initState();
    checkPermission();
    getContact();
  }
Color color =Colors.cyan;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: color,
          title: Text("TEST APP",style:TextStyle(color: Colors.white,fontSize: 20)),
          actions: [
            Row(
              children: [
                Text('Add all',style: TextStyle(color: Colors.white,fontSize: 10),),
                Checkbox(
                    activeColor: color,
                    value: checkVal,
                    onChanged: ( value) {
                      bool val =checkVal;
                      setState(() {
                        if(val==false){
                          selectedNames=0;
                          for(var i =0; i<nameNumber.length;i++){
                            if(nameNumber[i].isChecked==false){
                              nameNumber[i].isChecked=true;
                            }
                            if(nameNumber[i].isChecked==true){
                              selectedNames+=1;
                            }else{
                              selectedNames-=1;
                            }
                          }
                          checkVal=!checkVal;
                        }else{
                          for(var i =0; i<nameNumber.length;i++){
                            if(nameNumber[i].isChecked==true){
                              nameNumber[i].isChecked=false;
                            }
                            if(nameNumber[i].isChecked==true){
                              selectedNames+=1;
                            }else{
                              selectedNames-=1;
                            }
                          }
                          checkVal=!checkVal;
                        }
                        if(selectedNames<=0){selectedNames=0;}
                      });
                    }),

              ],
            )
          ]
      ),
      body: SafeArea(
          child:ListView.builder(itemCount: nameNumber.length,itemBuilder:(context,index){
            NameNumber contact = nameNumber[index];
            return ListTile(
              title: Text('${contact.number}'),
              subtitle: Text('${contact.name}'),
              trailing: Checkbox(
                  activeColor: color,
                  value: contact.isChecked,
                  onChanged: ( value) {
                    setState(() {
                      contact.isChecked = value!;
                      contact.isChecked? selectedNames+=1: selectedNames-=1;
                    });
                  }),
            );
          } )
      )
      ,bottomNavigationBar: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ButtonBar(
          children: [

            IconButton(onPressed: (){
            for(var i = 0 ; i<nameNumber.length ; i++) {
              if(nameNumber[i].isChecked==true){
                checkedList.add(nameNumber[i]);
              }else{
                continue;
              }
            }
            showDialog<String>(
              context: context,
              builder: (BuildContext context) =>
                  AlertDialog(
                title:  Text('Selected Name\\s  ${selectedNames!=0?selectedNames:0} '),
                content:  Text('Are you sure that you want to upload  to your account'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () =>{
                      normalState()

                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => {
                      sendData(checkedList),
                      Navigator.pop(context)
                    },
                    child: const Text('Send'),
                  ),
                ],
              ),
            );
            },
              icon:Icon(Icons.bookmarks_outlined,color: color,size:30 ,)
          ),
        ],
        ),
      ],
    ),
    );
  }
}
