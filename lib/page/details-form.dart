// Screen for entering user details

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_template/core/http/http.dart';
import 'package:flutter_template/core/utils/privacy.dart';
import 'package:flutter_template/core/utils/toast.dart';
import 'package:flutter_template/core/widget/loading_dialog.dart';
import 'package:flutter_template/generated/i18n.dart';
import 'package:flutter_template/page/index.dart';
import 'package:flutter_template/page/menu/register.dart';
import 'package:flutter_template/utils/provider.dart';
import 'package:flutter_template/utils/sputils.dart';

class DetailsFormPage extends ConsumerStatefulWidget {
  @override
  _DetailsFormPageState createState() => _DetailsFormPageState();
}

class _DetailsFormPageState extends ConsumerState<DetailsFormPage> {
  // 响应空白处的焦点的Node
  FocusNode blankNode = FocusNode();
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _otherNamesController = TextEditingController();
  //TextEditingController _phoneController = TextEditingController();
  GlobalKey _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // if (!SPUtils.isAgreePrivacy()!) {
    //   PrivacyUtils.showPrivacyDialog(context, onAgressCallback: () {
    //     Navigator.of(context).pop();
    //     SPUtils.saveIsAgreePrivacy(true);
    //     ToastUtils.success(I18n.of(context)!.agreePrivacy);
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return 
      // PopScope(
      //   canPop: false,
      //   child: 
        Scaffold(
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
                  child: buildForm(context),
                ),
              ),
              // const SizedBox(height: 32)
              
          ],)
          
            
        );
      //   onPopInvokedWithResult: (didPop, result) async {
      //   }
      // );
  }

  //构建表单
  Widget buildForm(BuildContext context) {
    return Form(
      key: _formKey, //设置globalKey，用于后面获取FormState
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        children: <Widget>[
          Center(
            heightFactor: 1.5,
            child: FlutterLogo(
              size: 64,
          )),
          Text(
            I18n.of(context)!.enterEmailPhone,
            textAlign: TextAlign.center,
          ),
          TextFormField(
            autofocus: false,
            controller: _surnameController,
            decoration: InputDecoration(
                labelText: I18n.of(context)!.email,
                hintText: I18n.of(context)!.emailHint,
                hintStyle: TextStyle(fontSize: 12),
                icon: Icon(Icons.email)),
            //校验用户名
            validator: (v) {
              return v!.trim().length > 0
                  ? null
                  : I18n.of(context)!.emailError;
          }),
          // phone
          TextFormField(
            autofocus: false,
            controller: _otherNamesController,
            decoration: InputDecoration(
                labelText: I18n.of(context)!.phone,
                hintText: I18n.of(context)!.phoneHint,
                hintStyle: TextStyle(fontSize: 12),
                icon: Icon(Icons.phone)),
            //校验用户名
            validator: (v) {
              return v!.trim().length > 0
                  ? null
                  : I18n.of(context)!.phoneError;
          }),
          TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                  labelText: I18n.of(context)!.password,
                  hintText: I18n.of(context)!.passwordHint,
                  hintStyle: TextStyle(fontSize: 12),
                  icon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                      icon: Icon(
                        _isShowPassWord
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black,
                      ),
                      onPressed: showPassWord)),
              obscureText: !_isShowPassWord,
              //校验密码
              validator: (v) {
                return v!.trim().length >= 6
                    ? null
                    : I18n.of(context)!.passwordError;
              }),
          // 登录按钮
          Padding(
            padding: const EdgeInsets.only(top: 28.0),
            child: Row(
              children: <Widget>[
                Expanded(child: Builder(builder: (context) {
                  return ElevatedButton(
                    style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.all(15.0)),
                    child: Text(I18n.of(context)!.login,
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      //由于本widget也是Form的子代widget，所以可以通过下面方式获取FormState
                      if (Form.of(context)!.validate()) {
                        onSubmit(context);
                      }
                    },
                  );
                })),
              ],
            ),
          ),

          //
          // TODO: forgot password
          // Register
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(I18n.of(context)!.noAccountQuestion),
              TextButton(
                child: Text(I18n.of(context)!.register,
                    style: TextStyle(color: Colors.blueAccent)),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                    builder: (context) {
                      return RegisterPage();
                    }),
                    (_)=> false
                  );
                },
              )
            ],
          ),
        ],
      ),
    );
  }

  ///点击控制密码是否显示
  void showPassWord() {
    setState(() {
      _isShowPassWord = !_isShowPassWord;
    });
  }

  void closeKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(blankNode);
  }

  //验证通过提交数据
  void onSubmit(BuildContext context) {
    closeKeyboard(context);

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(
            showContent: false,
            backgroundColor: Colors.black38,
            loadingView: SpinKitCircle(color: Colors.white),
          );
        });    

    XHttp.postJson("/user/login", {
      "username": _surnameController.text,
      "password": _phoneController.text
    }).then((response) {
      Navigator.pop(context);
      if (response['errorCode'] == 0) {
        ref.read(userProfileProvider.notifier).changeNickName(response['data']['nickname']);
        ToastUtils.toast(I18n.of(context)!.loginSuccess);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) {
            return MainHomePage();
          },
        ));
      } else {
        ToastUtils.error(response['errorMsg']);
      }
    }).catchError((onError) {
      Navigator.of(context).pop();
      ToastUtils.error(onError);
    });
  }
}
