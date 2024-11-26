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
            title: Text(I18n.of(context)!.enterDetails),
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
          TextFormField(
            autofocus: false,
            controller: _surnameController,
            decoration: InputDecoration(
              labelText: I18n.of(context)!.surname,
              //icon: Icon(Icons.text_fields)
            )
          ),
          // phone
          TextFormField(
            autofocus: false,
            controller: _otherNamesController,
            decoration: InputDecoration(
                labelText: I18n.of(context)!.otherNames,
                //icon: Icon(Icons.phone)
            ),
          ),

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
      ),
    );
  }


  void closeKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(blankNode);
  }

  //验证通过提交数据
  Future onSubmit(BuildContext context) async {
    debugPrint('on submit clicked...');
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
      }
    );

    String surname = _surnameController.text.trim();
    String otherNames = _otherNamesController.text.trim();
    Map<String,dynamic> dataSend = {};
    if (_surnameController.text.isNotEmpty) dataSend['surname'] = surname;
    if (_otherNamesController.text.isNotEmpty) dataSend['otherNames'] = otherNames;
    debugPrint('data to send: $dataSend');

    // init spf for saving surname, otherNames
    var spf = await SPUtils.init();
    await spf!.setString('surname', surname);
    await spf.setString('otherNames', otherNames);

    try {
      var response = await XHttp.putJson("/profile", dataSend);
      Navigator.pop(context); // pop spinner/loading dialog
      debugPrint('PUT /profile response: $response');
      int status = response.statusCode;
      var resBody = response.data;

      // TODO: status 401 goto login screen
      if (status == 200) { // go to home page
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) {
            return MainHomePage();
          }),
          (_)=> false
        );
      } else if (status == 400) { // display error message
        debugPrint('otp confirm error: ${resBody?.errMsg}');
        ToastUtils.error(resBody?.errMsg);
      } else {
        debugPrint('otp confirm error 500');
        ToastUtils.error(I18n.of(context)!.somethingWentWrong);
      }
    } catch (exc) {
      debugPrint('caught PUT /profile error: $exc');
      // Navigator.of(context).pop(); // TODO: only pop conditionally if not popped in try block
      ToastUtils.error(I18n.of(context)!.somethingWentWrong);
    }
      
    // }).catchError((onError) {
      
    // });
  }
}
