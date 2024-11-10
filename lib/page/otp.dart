// Enter OTP while signing up or logging in

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_template/core/http/http.dart';
import 'package:flutter_template/core/utils/toast.dart';
import 'package:flutter_template/core/widget/loading_dialog.dart';
import 'package:flutter_template/generated/i18n.dart';
import 'package:flutter_template/page/index.dart';
import 'package:flutter_template/utils/provider.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter_template/page/details-form.dart';
import 'package:flutter_template/utils/sputils.dart';



class OtpPage extends ConsumerStatefulWidget {
  final bool isLogin;
  String email;
  String phone;


  OtpPage({Key? key, this.isLogin = true, this.email="", this.phone=""}) : super(key: key);

  @override
  _OtpPageState createState() => _OtpPageState(isLogin, email, phone);
}


class _OtpPageState extends ConsumerState<OtpPage> {
  FocusNode blankNode = FocusNode();
  TextEditingController _otpController = TextEditingController();
  final bool isLogin;
  String email;
  String phone;

  _OtpPageState(this.isLogin, this.email, this.phone) : super();


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: _leading(context),
        //title: Text(I18n.of(context)!.login),
        //actions: <Widget>[],
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              // 点击空白页面关闭键盘
              closeKeyboard(context);
            },
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              child: Column(
                children: [
                   TextFormField( // TODO: numbers only after updating server
                      autofocus: false,
                      controller: _otpController,
                      decoration: InputDecoration(
                          labelText: I18n.of(context)!.otp,
                          //hintText: I18n.of(context)!.emailHint,
                          //hintStyle: TextStyle(fontSize: 12),
                          icon: Icon(Icons.pin)),
                      //校验用户名
                      validator: (v) {
                        return v!.trim().length > 0
                            ? null
                            : I18n.of(context)!.otpError;
                    }),
                    // TextButton(
                    //   child: Text(I18n.of(context)!.submit,
                    //       style: TextStyle(color: Colors.blueAccent)),
                    //   onPressed: () {
                    //     debugPrint('Submit otp button pressed');
                    //   },
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(top: 28.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Builder(builder: (context) {
                            return ElevatedButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).primaryColor,
                                padding: EdgeInsets.all(15.0),
                              ),
                              child: Text(I18n.of(context)!.submit,
                                  style: TextStyle(color: Colors.white)),
                              onPressed: () {
                                  onSubmit(context);
                              },
                            );
                          })),
                        ],
                      ),
                    ),
                ],
              )
            ),
          ),
          // const SizedBox(height: 32)
          
      ],)
      
        
    );
  }


  void closeKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(blankNode);
  }


  /// handler for submitting OTP
  Future onSubmit(BuildContext context) async {
    closeKeyboard(context);

    // show loading dialog/spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingDialog(
          showContent: false,
          backgroundColor: Colors.black38,
          loadingView: SpinKitCircle(color: Colors.white),
        );
      }
    );

    // send data
    debugPrint('onSubmit otp. isLogin: $isLogin');
    var url = isLogin ? '/login/confirm' : '/signup/confirm';

    var dataSend = {"code": _otpController.text.trim()};
    if (email.isNotEmpty) dataSend["email"] = email;
    if (phone.isNotEmpty) dataSend["phone"] = phone;

    debugPrint('data to send: $dataSend');
    try {
      var response = await XHttp.putJson(url, dataSend);
      int status = response.statusCode;
      debugPrint('/confirm status: $status');
      var resBody = response.data;

      //
      if (status == 200) { // succeeded, either go to home page or 'enter details' page
        // cookie was returned and saved by DIO interceptor. Indicate cookie saved
        await SPUtils.setHasCookie(true);

        debugPrint('resBody: $resBody');
        bool isUserDataSet = resBody['surname'] !=null && resBody['otherNames'] != null;
        debugPrint('isUserDataSet: $isUserDataSet');
        // go to homepage if user data set, else data entry page
        //ConsumerStatefulWidget nextScreen = isUserDataSet ? MainHomePage : MainHomePage;
        if (isUserDataSet) { // go to homepage
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (context) {
              return MainHomePage();
            }),
            (_)=> false
          );
        } else { // go to screen for entering user details
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (context) {
              return DetailsFormPage();
            }),
            (_)=> false
          );
        }

      } else if (status == 400) {
        debugPrint('otp confirm error: ${resBody?.errMsg}');
        ToastUtils.error(resBody?.errMsg);
      } else {
        debugPrint('otp confirm error 500');
        ToastUtils.error(I18n.of(context)!.somethingWentWrong);
      }
    } catch (exc) {
      debugPrint('otp confirm exc: $exc');
      ToastUtils.error(I18n.of(context)!.somethingWentWrong);
    }



  }



}
