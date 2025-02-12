import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/repository.dart';

///page for playlist edit
class PlaylistEditPage extends StatefulWidget {
  const PlaylistEditPage(this.playlist, {Key? key}) : super(key: key);
  final PlaylistDetail playlist;

  @override
  _PlaylistEditPageState createState() => _PlaylistEditPageState();
}

class _PlaylistEditPageState extends State<PlaylistEditPage> {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyText2!.copyWith(
        fontSize: 15,
        shadows: [
          const Shadow(offset: Offset(0.3, 0.3), color: Colors.black87)
        ]);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("编辑歌单信息"),
      ),
      body: Builder(builder: (context) {
        return Column(
          children: <Widget>[
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                showSimpleNotification(const Text("Not implemented"),
                    background: Theme.of(context).errorColor);
              },
              child: Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(child: Text("更换封面", style: style)),
                    Image(
                        image: CachedImage(widget.playlist.coverUrl),
                        height: 56,
                        width: 56)
                  ],
                ),
              ),
            ),
            const Divider(height: 0, indent: 8),
            InkWell(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return _PlaylistNameEditPage(widget.playlist);
                }));
              },
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(child: Text("名称", style: style)),
                    Text(widget.playlist.name)
                  ],
                ),
              ),
            ),
            const Divider(height: 0, indent: 8),
            InkWell(
              onTap: () {
                showSimpleNotification(const Text("Not implemented"),
                    background: Theme.of(context).errorColor);
              },
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(child: Text("标签", style: style)),
                    Text("功能未实现", style: Theme.of(context).textTheme.caption)
                  ],
                ),
              ),
            ),
            const Divider(height: 0, indent: 8),
            InkWell(
              onTap: () {
                showSimpleNotification(const Text("Not implemented"),
                    background: Theme.of(context).errorColor);
              },
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(child: Text("描述", style: style)),
                    Text(widget.playlist.name)
                  ],
                ),
              ),
            ),
            const Divider(height: 0, indent: 8),
          ],
        );
      }),
    );
  }
}

class _PlaylistNameEditPage extends StatefulWidget {
  const _PlaylistNameEditPage(this.playlist, {Key? key}) : super(key: key);
  final PlaylistDetail? playlist;

  @override
  _PlaylistNameEditPageState createState() {
    return _PlaylistNameEditPageState();
  }
}

class _PlaylistNameEditPageState extends State<_PlaylistNameEditPage> {
  String? error;

  TextEditingController? _controller;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.playlist!.name);
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("歌单名称"),
        actions: <Widget>[
          TextButton(
              onPressed: () async {
                // TODO update playlist name
                // _focusNode.unfocus();
                // final name = widget.playlist!.name;
                // widget.playlist!.name = _controller!.text;
                // try {
                //   final bool succeed = await showLoaderOverlay(context,
                //       neteaseRepository!.updatePlaylist(widget.playlist!));
                //   if (succeed) {
                //     Navigator.pop(context, true);
                //   } else {
                //     setState(() {
                //       widget.playlist!.name = name;
                //       error = "修改失败";
                //     });
                //   }
                // } catch (msg) {
                //   setState(() {
                //     widget.playlist!.name = name;
                //     error = msg.toString();
                //   });
                // }
              },
              child: const Text("保存"))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _controller,
              maxLength: 40,
              autofocus: true,
              focusNode: _focusNode,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                  hintText: "编辑歌单名称",
                  errorText: error,
                  suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _controller!.text = "";
                      })),
              validator: (v) {
                if (v!.isEmpty) {
                  return "歌单名不能为空";
                }
                return null;
              },
            )
          ],
        ),
      ),
    );
  }
}
