// Enter OTP while signing up or logging in

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_template/core/http/http.dart';
import 'package:flutter_template/core/utils/toast.dart';
import 'package:flutter_template/core/widget/loading_dialog.dart';
import 'package:flutter_template/generated/i18n.dart';
import 'package:flutter_template/page/index.dart';
import 'package:flutter_template/utils/provider.dart';
import 'package:flutter/foundation.dart';



class OtpPage extends ConsumerStatefulWidget {
  final bool isLogin;

  OtpPage({Key? key, this.isLogin = true}) : super(key: key);

  @override
  _OtpPageState createState() => _OtpPageState();
}


class _OtpPageState extends ConsumerState<OtpPage> {
  FocusNode blankNode = FocusNode();
  TextEditingController _otpController = TextEditingController();

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
                   TextFormField(
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
                    TextButton(
                      child: Text(I18n.of(context)!.submit,
                          style: TextStyle(color: Colors.blueAccent)),
                      onPressed: () {
                        debugPrint('Submit otp button pressed');
                      },
                    )
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
}
