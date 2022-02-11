import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import 'package:music_player/music_player.dart';
import 'package:netease_music_api/netease_cloud_music.dart' as api;
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiet/component.dart';
import 'package:quiet/pages/splash/page_splash.dart';
import 'package:quiet/repository/netease.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // 确定已经初始化完成
  WidgetsFlutterBinding.ensureInitialized();
  // TODO
  neteaseRepository = NeteaseRepository();
  api.debugPrint = debugPrint;
  // 设置日志格式
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.time} ${record.level.name} '
        '${record.loggerName}: ${record.message}');
  });

  // flutter沙盒捕获异常
  runZonedGuarded(() {
    // runApp 项目启动入口函数
    // 初始化riverpod状态管理
    runApp(ProviderScope(
      // 闪屏页
      child: PageSplash(
        // 需要初始化的数据List
        futures: [
          // 临时存储初始化
          SharedPreferences.getInstance(),
          // 获取文件存储位置，将Hive初始化
          getApplicationDocumentsDirectory().then((dir) {
            Hive.init(dir.path);
            return Hive.openBox<Map>('player');
          }),
        ],
        builder: (BuildContext context, List<dynamic> data) {
          return MyApp(
            setting: Settings(data[0] as SharedPreferences),
            player: data[1] as Box<Map>,
          );
        },
      ),
    ));
  }, (error, stack) {
    debugPrint('uncaught error : $error $stack');
  });
}

/// The entry of dart background service
/// NOTE: this method will be invoked by native (Android/iOS)
@pragma('vm:entry-point') // avoid Tree Shaking
void playerBackgroundService() {
  WidgetsFlutterBinding.ensureInitialized();
  // 获取播放地址需要使用云音乐 API, 所以需要为此 isolate 初始化一个 repository.
  neteaseRepository = NeteaseRepository();
  runBackgroundService(
    imageLoadInterceptor: BackgroundInterceptors.loadImageInterceptor,
    playUriInterceptor: BackgroundInterceptors.playUriInterceptor,
    playQueueInterceptor: QuietPlayQueueInterceptor(),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({
    Key? key,
    required this.setting,
    this.player,
  }) : super(key: key);

  final Settings setting;

  final Box<Map>? player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScopedModel<Settings>(
      model: setting,
      child:
          ScopedModelDescendant<Settings>(builder: (context, child, setting) {
        return Netease(
          child: Quiet(
            box: player,
            child: OverlaySupport(
              child: MaterialApp(
                routes: routes,
                onGenerateRoute: routeFactory,
                title: 'Quiet',
                supportedLocales: const [Locale("en"), Locale("zh")],
                localizationsDelegates: const [
                  S.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                ],
                theme: setting.theme,
                darkTheme: setting.darkTheme,
                themeMode: setting.themeMode,
                initialRoute: pageMain,
              ),
            ),
          ),
        );
      }),
    );
  }
}
