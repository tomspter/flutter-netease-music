import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:quiet/component.dart';
import 'package:quiet/component/global/orientation.dart';
import 'package:quiet/material/landscape.dart';
import 'package:quiet/pages/main/main_page_discover.dart';
import 'package:quiet/pages/search/page_search.dart';
import 'package:quiet/part/part.dart';

import 'drawer.dart';
import 'my/main_page_my.dart';

// part 'page_main_landscape.dart';
part 'page_main_portrait.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 根据屏幕方向进入不同主页 _PortraitMainPage 竖屏
    // return context.isLandscape ? _LandscapeMainPage() : _PortraitMainPage();
    return _PortraitMainPage();
  }
}

// extension LandscapeMainContext on BuildContext {
//   /// Obtain the primary navigator for landscape mode.
//   NavigatorState? get landscapePrimaryNavigator =>
//       findAncestorStateOfType<_LandscapeMainPageState>()!
//           ._landscapeNavigatorKey
//           .currentState;
//
//   /// Obtain the secondary navigator for landscape mode.
//   NavigatorState? get landscapeSecondaryNavigator {
//     final key = read<LandscapeSecondaryKey>();
//     return key.currentState;
//   }
// }
