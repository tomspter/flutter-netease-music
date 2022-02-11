import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:quiet/repository/netease.dart';
import 'package:scoped_model/scoped_model.dart';

class MyCollectionApi extends Model {
  static MyCollectionApi of(BuildContext context) {
    return ScopedModel.of<MyCollectionApi>(context);
  }

  // 获取已收藏专辑列表
  Future<Result<Map>> getAlbums() {
    return neteaseRepository!.doRequest('/album/sublist');
  }

  // 获取已收藏歌手列表
  Future<Result<Map>> getArtists() {
    return neteaseRepository!.doRequest('/artist/sublist');
  }
}
