import 'package:flutter/material.dart';
import 'package:quiet/component.dart';
import 'package:quiet/component/global/settings.dart';
import 'package:quiet/component/route.dart';

import 'material.dart';

export 'setting_theme_page.dart';

/// App 设置页面
class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        titleSpacing: 0,
      ),
      body: ListView(
        children: <Widget>[
          SettingGroup(
            title: '通用',
            children: <Widget>[
              ListTile(
                title: const Text('更换主题'),
                onTap: () =>
                    context.secondaryNavigator!.pushNamed(pageSettingTheme),
              ),
              // _CopyRightCheckBox(),
            ],
          )
        ],
      ),
    );
  }
}
