import 'package:flutter/material.dart';
import 'page_login_phone.dart';

const pageLoginPhone = "loginWithPhone";

///登录子流程
class LoginNavigator extends StatelessWidget {
  const LoginNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: pageLoginPhone,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
            settings: settings, builder: (context) => _generatePage(settings)!);
      },
    );
  }

  Widget? _generatePage(RouteSettings settings) {
    return PageLoginWithPhone();
  }
}
