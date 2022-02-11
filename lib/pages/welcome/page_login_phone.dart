import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component.dart';
import 'package:quiet/material/dialogs.dart';
import 'package:quiet/model/region_flag.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository.dart';

import 'login_sub_navigation.dart';
import 'page_dia_code_selection.dart';

/// Read emoji flags from assets.
Future<List<RegionFlag>> _getRegions() async {
  final jsonStr =
  await rootBundle.loadString("assets/emoji-flags.json", cache: false);
  final flags = json.decode(jsonStr) as List;
  final result =
  flags.cast<Map>().map((map) => RegionFlag.fromMap(map)).where((flag) {
    return flag.dialCode != null && flag.dialCode!.trim().isNotEmpty;
  }).toList();
  return result;
}

class PageLoginWithPhone extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final regions = useFuture(useMemoized(() => _getRegions()));
    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.loginWithPhone),
        leading: IconButton(
          icon: const BackButtonIcon(),
          tooltip: MaterialLocalizations
              .of(context)
              .backButtonTooltip,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).maybePop();
          },
        ),
      ),
      body: regions.hasData
          ? _PhoneInputLayout(regions: regions.requireData)
          : const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _PhoneInputLayout extends HookConsumerWidget {
  const _PhoneInputLayout({
    Key? key,
    required this.regions,
  }) : super(key: key);

  final List<RegionFlag> regions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _phoneInputController = useTextEditingController();
    final _pwdInputController = useTextEditingController();

    final selectedRegion = useState<RegionFlag>(useMemoized(() {
      // initial to select system default region.
      final countryCode = window.locale.countryCode;
      return regions.firstWhere((region) => region.code == countryCode,
          orElse: () => regions[0]);
    }));

    Future<void> onNextClick() async {
      final text = _phoneInputController.text;
      final pwd = _pwdInputController.text;
      if (text.isEmpty || pwd.isEmpty) {
        toast("请输入完整登录信息");
        return;
      }
      final checkPhoneResult = await showLoaderOverlay(
        context,
        ref.read(loginApiProvider).checkPhoneExist(
          text,
          selectedRegion.value.dialCode!
              .replaceAll("+", "")
              .replaceAll(" ", ""),
        ),
      );
      if (checkPhoneResult.isError) {
        toast(checkPhoneResult.asError!.error.toString());
        return;
      }
      final value = checkPhoneResult.asValue!.value;
      if (!value.isExist || !value.hasPassword!) {
        toast('核对登录信息或者选择扫码登录');
        return;
      }
      final loginResult = await showLoaderOverlay(context,
          ref.read(userProvider.notifier).login(text, pwd)
      );
      if (loginResult.isValue) {
        Navigator.of(context, rootNavigator: true).pop(true);
      } else {
        toast('登录失败:${loginResult.asError!.error}');
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 30),
          Text(
            context.strings.tipsAutoRegisterIfUserNotExist,
            style: Theme
                .of(context)
                .textTheme
                .caption,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: _PhoneInput(
              controller: _phoneInputController,
              selectedRegion: selectedRegion.value,
              onPrefixTap: () async {
                final RegionFlag? region = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return RegionSelectionPage(regions: regions);
                  }),
                );
                if (region != null) {
                  selectedRegion.value = region;
                }
              },
              onDone: onNextClick,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: TextField(
              controller: _pwdInputController,
              obscureText: true,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(hintText: '请输入密码'),
            ),
          ),
          _ButtonNextStep(onTap: onNextClick),
        ],
      ),
    );
  }
}

class _PhoneInput extends HookWidget {
  const _PhoneInput({
    Key? key,
    required this.controller,
    required this.selectedRegion,
    required this.onPrefixTap,
    required this.onDone,
  }) : super(key: key);

  final TextEditingController controller;

  final RegionFlag selectedRegion;

  final VoidCallback onPrefixTap;

  final VoidCallback onDone;

  Color? _textColor(BuildContext context) {
    if (controller.text.isEmpty) {
      return Theme
          .of(context)
          .disabledColor;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.bodyText2!.copyWith(
      fontSize: 16,
      color: _textColor(context),
    );
    useListenable(controller);
    return TextField(
      autofocus: true,
      style: style,
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      onSubmitted: (text) => onDone(),
      decoration: InputDecoration(
        prefix: InkWell(
          onTap: onPrefixTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              "${selectedRegion.emoji} ${selectedRegion.dialCode!}",
              style: style,
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonNextStep extends StatelessWidget {
  const _ButtonNextStep({Key? key, required this.onTap}) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Theme
            .of(context)
            .primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: Theme
            .of(context)
            .primaryTextTheme
            .bodyText2,
        padding: const EdgeInsets.symmetric(vertical: 18),
      ),
      onPressed: onTap,
      child: Text(context.strings.login),
    );
  }
}
