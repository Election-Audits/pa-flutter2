import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_template/core/http/http.dart';
import 'package:flutter_template/core/utils/toast.dart';
import 'package:flutter_template/core/widget/loading_dialog.dart';
import 'package:flutter_template/generated/i18n.dart';
import 'package:flutter_template/page/menu/login.dart';
import 'package:flutter_template/page/otp.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 响应空白处的焦点的Node
  bool _isShowPassWord = false;
  bool _isShowPassWordRepeat = false;
  FocusNode blankNode = FocusNode();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  TextEditingController _pwdRepeatController = TextEditingController();
  GlobalKey _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(), // title: Text(I18n.of(context)!.register)
      body: GestureDetector(
        onTap: () {
          // 点击空白页面关闭键盘
          closeKeyboard(context);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          child: buildForm(context),
        ),
      ),
    );
  }

  //构建表单
  Widget buildForm(BuildContext context) {
    return Form(
      key: _formKey, //设置globalKey，用于后面获取FormState
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
            controller: _emailController,
            decoration: InputDecoration(
                labelText: I18n.of(context)!.email,
                hintText: I18n.of(context)!.emailHint,
                hintStyle: TextStyle(fontSize: 12),
                icon: Icon(Icons.email)),
            //校验用户名
            // validator: (v) {
            //   return v!.trim().length > 0
            //       ? null
            //       : I18n.of(context)!.emailError;
            // }
          ),
          // phone
          TextFormField(
            autofocus: false,
            controller: _phoneController,
            decoration: InputDecoration(
                labelText: I18n.of(context)!.phone,
                hintText: I18n.of(context)!.phoneHint,
                hintStyle: TextStyle(fontSize: 12),
                icon: Icon(Icons.phone)),
            //校验用户名
            // validator: (v) {
            //   return v!.trim().length > 0
            //       ? null
            //       : I18n.of(context)!.phoneError;
            // }
          ),
          TextFormField(
              controller: _pwdController,
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
              validator: (v) { // .trim()
                return v!.length >= 6
                    ? null
                    : I18n.of(context)!.passwordError;
              }),

          TextFormField(
              controller: _pwdRepeatController,
              decoration: InputDecoration(
                  labelText: I18n.of(context)!.repeatPassword,
                  hintText: I18n.of(context)!.passwordHint,
                  hintStyle: TextStyle(fontSize: 12),
                  icon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                      icon: Icon(
                        _isShowPassWordRepeat
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black,
                      ),
                      onPressed: showPassWordRepeat)),
              obscureText: !_isShowPassWordRepeat,
              //校验密码
              validator: (v) {
                var pwd_0 = _pwdController.text;
                return (pwd_0 == v) ? null : I18n.of(context)!.passwordsNotEqual;
                // return v!.trim().length >= 6
                //     ? null
                //     : I18n.of(context)!.passwordError;
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
                      padding: EdgeInsets.all(15.0),
                    ),
                    child: Text(I18n.of(context)!.register,
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
          // Login if have account
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(I18n.of(context)!.haveAccountQuestion),
              TextButton(
                child: Text(I18n.of(context)!.login,
                    style: TextStyle(color: Colors.blueAccent)),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                    builder: (context) {
                      return LoginPage();
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

  ///点击控制密码是否显示
  void showPassWordRepeat() {
    setState(() {
      _isShowPassWordRepeat = !_isShowPassWordRepeat;
    });
  }

  void closeKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(blankNode);
  }

  //验证通过提交数据
  void onSubmit(BuildContext context) {
    closeKeyboard(context);
    // NB: password equality checked in input validator

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

    var dataSend = {"password": _pwdController.text};
    var email = _emailController.text.trim();
    var phone = _phoneController.text.trim(); // TODO: setting country code in form
    // using either email or phone, check before sending
    if (_emailController.text.isNotEmpty) {
      dataSend['email'] = email;
    }
    if (_phoneController.text.isNotEmpty) {
      dataSend['phone'] = phone;
    }


    XHttp.postJson("/signup", dataSend)
    .then((response) {
      Navigator.of(context).pop(); // pop loading dialog/spinner
      debugPrint('/signup response: $response');
      var status = response.statusCode;
      debugPrint('status code: $status');
      if (status == 200) { // transition to OTP screen
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return OtpPage(isLogin: false, email: email, phone: phone);
          })
        );
      } else if (status == 400) { // display error message that was sent
        debugPrint('/signup error: ${response?.data['errMsg']}');
        ToastUtils.error(response?.data['errMsg']);
      } else { // something went wrong
        debugPrint('/signup error 500');
        ToastUtils.error(I18n.of(context)!.somethingWentWrong);
      }

      //
      // Navigator.pop(context);
      // if (response['errorCode'] == 0) {
      //   ToastUtils.toast(I18n.of(context)!.registerSuccess);
      //   Navigator.of(context).pop();
      // } else {
      //   ToastUtils.error(response['errorMsg']);
      // }
    }).catchError((onError) {
      debugPrint('caught /signup error: $onError');
      //Navigator.of(context).pop(); // pop loading dialog
      ToastUtils.error(onError);
    });
  }
}
