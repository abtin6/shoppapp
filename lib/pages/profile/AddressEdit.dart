import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:persian_numbers/persian_numbers.dart';
import 'package:shopapp/components/InputField.dart';
import 'package:shopapp/services/authenticate.dart';
import 'package:shopapp/constants.dart' as Const;
import 'package:validators/validators.dart';

class AddressEdit extends StatefulWidget {
  final String ID;

  AddressEdit({Key key, @required this.ID}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() => AddressEditState();

}
class AddressEditState extends State<AddressEdit> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController nameController = new TextEditingController();
  TextEditingController pcodeController = new TextEditingController();
  TextEditingController telController = new TextEditingController();
  TextEditingController addrController = new TextEditingController();
  String dropdownValue;
  String cityDefaultValue;
  static List<dynamic> provinceList = [];
  static List<dynamic> cityList = [];
  Map addrData;


  void _getAddrData(ID) async{
    Map response = await AuthService.sendDataToServer({'id': ID}, 'getAddrData');
    setState(() {
      addrData = jsonDecode(response['result']['data']);
      nameController = new TextEditingController(text: addrData['name']);
      pcodeController = new TextEditingController(text: addrData['pcode'].toString());
      telController = new TextEditingController(text: addrData['tel'].toString());
      addrController = new TextEditingController(text: addrData['addr']);
    });

  }

  _getProvinces() async{
    Map response = await AuthService.sendDataToServer({}, 'getProvinces');
    setState(() {
      provinceList = jsonDecode(response['result']['data']);
    });
    // loop in the map and getting all the keys
    for(var i = 0; i < provinceList.length; i++) {
      menuItems.add(
          DropdownMenuItem<String>(
            // items[key] this instruction get the value of the respective key
            child: Text(provinceList[i]['name']), // the value as text label
            value: provinceList[i]['id'].toString(), // the respective key as value
          ));
    }
    dropdownValue = menuItems[0].value;
  }
  _getCities(provinceID) async{
    Map response = await AuthService.sendDataToServer({'id': provinceID}, 'getCities');
    setState(() {
      cityList = jsonDecode(response['result']['data']);
      cityItems.clear();
      for(var i = 0; i < cityList.length; i++) {
        cityItems.add(
            DropdownMenuItem<String>(
              // items[key] this instruction get the value of the respective key
              child: Text(cityList[i]['name']), // the value as text label
              value: cityList[i]['id'].toString(), // the respective key as value
            ));
      }
      cityDefaultValue = cityList[0]['id'].toString();
    });
  }

  // your list of DropDownMenuItem
  List< DropdownMenuItem<String>> menuItems = List();
  List< DropdownMenuItem<String>> cityItems = List();

  @override
  void initState() {
    // TODO: implement initState
    _getAddrData(widget.ID);
    _getProvinces();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    var deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('???????????? ????????'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: GestureDetector(onTap: (){ Navigator.pop(context); },child: Icon(Icons.close,color:  Color(0xFF424750))),
          )
        ],
      ),
      body: (addrData == null || addrData.length == 0) ? Center(child: CircularProgressIndicator())
        : Stack(
        children: <Widget>[
          ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('??????????*',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600),),
                          DropdownButton(
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            hint: Text('?????????? ???? ???????????? ????????'),
                            value: dropdownValue,
                            onChanged: (newValue) {
                              setState(() {
                                dropdownValue = newValue;
                                _getCities(newValue);
                              });
                            },
                            items: menuItems,
                          ),
                          Text('??????*',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600),),
                          DropdownButton(
                            isExpanded: true,
                            hint: Text('?????? ???? ???????????? ????????'),
                            dropdownColor: Colors.white,
                            value: cityDefaultValue,
                            onChanged: (newValue) {
                              setState(() {
                                cityDefaultValue = newValue;
                              });
                            },
                            items: cityItems,
                          ),
                          Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 10,),
                                  Align(
                                    child: Text('???????? ????????*',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600),),
                                    alignment: Alignment.topRight,
                                  ),
                                  SizedBox(height: 7,),
                                  InputFieldArea(
                                      controller: addrController,
                                      obscure: false,
                                      // ignore: missing_return
                                      validator: (String value) {if(!isLength(value, 2)) {
                                        return '???????? ???????? ???????? ???? ???????? ????????';
                                      }}
                                  ),
                                  SizedBox(height: 10,),
                                  Align(
                                    child: Text('???? ????????*',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600),),
                                    alignment: Alignment.topRight,
                                  ),
                                  SizedBox(height: 7,),
                                  InputFieldArea(
                                      controller: pcodeController,
                                      obscure: false,
                                      // ignore: missing_return
                                      validator: (String value) {
                                        var val = PersianNumbers.toEnglish(value);
                                        if(!isLength(val, 10)) {
                                        return '???????? ???????????? ???? ???????? ???? ???????? ????????';
                                      }}
                                  ),
                                  SizedBox(height: 10,),
                                  Align(
                                    child: Text('?????? ?? ?????? ???????????????? ????????????*',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600),),
                                    alignment: Alignment.topRight,
                                  ),
                                  SizedBox(height: 7,),
                                  InputFieldArea(
                                      controller: nameController,
                                      obscure: false,
                                      // ignore: missing_return
                                      validator: (String value) {if(!isLength(value, 2)) {
                                        return '???????? ???? ?????? ???????????????? ???????? ???????? ????????';
                                      }}
                                  ),
                                  SizedBox(height: 10,),
                                  Align(
                                    child: Text('?????????? ???????? ?????????? ????????????*',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600),),
                                    alignment: Alignment.topRight,
                                  ),
                                  SizedBox(height: 7,),
                                  InputFieldArea(
                                      controller: telController,
                                      obscure: false,
                                      // ignore: missing_return
                                      validator: (String value) {
                                        var val = PersianNumbers.toEnglish(value);
                                        if(!RegExp(r"09[0-9]{9}").hasMatch(val)) {
                                        return '???????? ?????????? ???????????? ???????? ????????';
                                      }}
                                  ),
                                  SizedBox(height: 50,)
                                ],
                              )
                          )
                        ],
                      )
                    ],
                  ),
                );
              }
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: deviceSize.width,
                height: 50,
                padding: EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: Const.LayoutColor,
                 // borderRadius: BorderRadius.circular(3),
                ),
                child: ElevatedButton(
                    onPressed: () async{
                      if(_formKey.currentState.validate()) {
                        //_formKey.currentState.save();
                        updateAddrData();
                        _formKey.currentState.reset();
                        FocusScope.of(context).unfocus();
                      }
                    },
                    child: Center(child: Text(' ?????? ???????? ', style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w400)))
                ),
              )
            ],
          )
        ],
      )

    );
  }

  updateAddrData() async {
    if(cityDefaultValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('?????? ???? ???????????? ????????',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.red,
          )
      );
    }else {
      Map response = await AuthService.sendDataToServer({
        'id': widget.ID,
        "name": nameController.text,
        "tel": telController.text,
        "pcode": pcodeController.text,
        "addr": addrController.text,
        "provinceID": dropdownValue,
        "CityID": cityDefaultValue,
      },'updateAddrData');
      if(response == null) { // Connection Failed
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('?????? ???? ?????????????? ???????????? ???? ????????',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
              backgroundColor: Colors.red,
            )
        );
      }else if(response['status']) {
        Navigator.pop(context);
      }else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['result']['message'],style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
              backgroundColor: Colors.red,
            )
        );
      }
    }

  }

}