import 'package:flutter/material.dart';
import 'package:persian_numbers/persian_numbers.dart';
import 'package:shopapp/components/InputField.dart';
import 'package:shopapp/models/user.dart';
import 'package:shopapp/pages/profile/AccountInfo.dart';
import 'package:shopapp/services/authenticate.dart';
import 'package:shopapp/constants.dart' as Const;
import 'package:validators/validators.dart';

class AccountEditPassword extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AccountEditPasswordState();

}
class AccountEditPasswordState extends State<AccountEditPassword> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  UserInfo userInfo;
  TextEditingController oldPasswordController = new TextEditingController();
  TextEditingController new1PasswordController = new TextEditingController();
  TextEditingController new2PasswordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {

    var deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: GestureDetector(onTap: (){ Navigator.pop(context); },child: Icon(Icons.close,color:  Color(0xFF424750))),
          )
        ],
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('تغییر رمزعبور',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600,color: Colors.black),),
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        InputFieldArea(
                            controller: oldPasswordController,
                            obscure: false, hint: "رمزعبور فعلی",
                            // ignore: missing_return
                            validator: (String value) {
                              var val = PersianNumbers.toEnglish(value);
                              if(!isLength(val, 6)) {
                              return 'رمزعبور شما باید حداقل 6 حرف باشد';
                            }}
                        ),
                        InputFieldArea(
                            controller: new1PasswordController,
                            obscure: false, hint: "رمزعبور جدید",
                            // ignore: missing_return
                            validator: (String value) {
                              var val = PersianNumbers.toEnglish(value);
                              if(!isLength(val, 6)) {
                              return 'رمزعبور شما باید حداقل 6 حرف باشد';
                            }}
                        ),
                        InputFieldArea(
                          controller: new2PasswordController,
                            obscure: false, hint: "تکرار رمزعبور جدید",
                            // ignore: missing_return
                            validator: (String value) {if(new1PasswordController.text != new2PasswordController.text) {
                              return 'تکرار رمزعبور با رمزعبور جدید یکسان نیست';
                            }}
                        ),
                      ],
                    )
                )
              ],
            ),
            Column(
              children: <Widget>[
                Container(
                  width: deviceSize.width,
                  height: 50,
                  padding: EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: Const.LayoutColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: ElevatedButton(
                      onPressed: () async{
                        if(_formKey.currentState.validate()) {
                          //_formKey.currentState.save();
                          storeUserData();
                          //_formKey.currentState.reset();
                          FocusScope.of(context).unfocus();
                        }
                      },
                      child: Center(child: Text('تغییر رمزعبور ', style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w400)))
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  storeUserData() async {
    Map response = await AuthService.sendDataToServer({ "oldPassword": oldPasswordController.text, "newPassword": new1PasswordController.text},'storeUserInfo');
    if(response == null) { // Connection Failed
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در برقراری ارتباط با سرور',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.red,
          )
      );
    }else if(response['status']) {
      Navigator.push (context, MaterialPageRoute( builder: (BuildContext context) => AccountInfoScreen() ) );
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