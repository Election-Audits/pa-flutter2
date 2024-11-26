// https://www.flutterlibrary.com/screens/sign-up-chat
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_template/generated/i18n.dart';
import 'package:flutter_template/utils/sputils.dart';
import 'package:flutter_template/page/menu/login.dart';


class ProfileScreen extends ConsumerStatefulWidget {

  @override
  _ProfileScreenStatea createState ()=> _ProfileScreenStatea(); 
}


class _ProfileScreenStatea extends ConsumerState<ProfileScreen> {

  String? _surname;
  String? _otherNames;
  String? _name;
  String? _email;
  String? _phone;

  @override
  void initState() {
    super.initState();
    setup(); // get _surname, etc. from shared prefs
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context)!.profile) ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(height: constraints.maxHeight * 0.08),
                Icon(Icons.account_circle, size: 100),
                SizedBox(height: constraints.maxHeight * 0.08),
                // Text(
                //   "Sign Up",
                //   style: Theme.of(context)
                //       .textTheme
                //       .headlineSmall!
                //       .copyWith(fontWeight: FontWeight.bold),
                // ),
                SizedBox(height: constraints.maxHeight * 0.05),
                // Form(
                //   key: _formKey,
                //   child: 
                  Column(
                    children: [
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: _name,
                          filled: true,
                          fillColor: Color(0xFFF5FCF9),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0 * 1.5, vertical: 16.0),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                        ),
                        onSaved: (name) {
                          // Save it
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: _email,
                          filled: true,
                          fillColor: Color(0xFFF5FCF9),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0 * 1.5, vertical: 16.0),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        onSaved: (phone) {
                          // Save it
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: _phone,
                            filled: true,
                            fillColor: Color(0xFFF5FCF9),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0 * 1.5, vertical: 16.0),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                          ),
                          obscureText: true,
                          onSaved: (passaword) {
                            // Save it
                          },
                        ),
                      ),

                      // Logout button
                      Padding(
                        padding: const EdgeInsets.only(top: 28.0),
                        child:
                          ElevatedButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor,
                              padding: EdgeInsets.fromLTRB(35, 15, 35, 15) //EdgeInsets.all(15.0),
                            ),
                            child: Text(I18n.of(context)!.logout,
                                style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                                (Route<dynamic> route) => false
                              );
                            },
                          ),
                      ),

                      // Deactivate button
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child:
                          ElevatedButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor,
                              padding: EdgeInsets.fromLTRB(35, 15, 35, 15),
                              backgroundColor: Colors.red
                            ),
                            child: Text(I18n.of(context)!.deactivate,
                                style: TextStyle(color: Colors.white)),
                            onPressed: () {
                            },
                          )
                      )

                    ],
                  ),
                // ),
              ],
            ),
          );
        }),
      ),
    );
  }


  // setup
  Future<void> setup() async {
    var spf = await SPUtils.init();
    _surname = await spf!.getString('surname');
    _otherNames = await spf.getString('otherNames');
    _email = await spf.getString('email');
    _phone = await spf.getString('phone');

    _name = (_otherNames != null) ? _otherNames : "";
    _name = (_surname != null) ? "$_name $_surname" : "$_name";

    debugPrint('name: $_name');
    debugPrint('email: $_email');
    debugPrint('phone: $_phone');

    setState((){
      _name = _name;
      _email = _email;
      _phone = _phone;
    });
  }


  // Logout
  Future<void> handleLogout() async {
    // TODO: backend
    Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => LoginPage(),
    ),
    (Route<dynamic> route) => false);
  }

}
