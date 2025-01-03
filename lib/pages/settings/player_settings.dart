import 'package:flutter/material.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:hive/hive.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/bean/settings/settings.dart';
import 'package:kazumi/utils/constants.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/utils/utils.dart';

class PlayerSettingsPage extends StatefulWidget {
  const PlayerSettingsPage({super.key});

  @override
  State<PlayerSettingsPage> createState() => _PlayerSettingsPageState();
}

class _PlayerSettingsPageState extends State<PlayerSettingsPage> {
  Box setting = GStorage.setting;
  late double defaultPlaySpeed;

  @override
  void initState() {
    super.initState();
    defaultPlaySpeed =
        setting.get(SettingBoxKey.defaultPlaySpeed, defaultValue: 1.0);
  }

  void onBackPressed(BuildContext context) {
    // Navigator.of(context).pop();
  }

  void updateDefaultPlaySpeed(double speed) {
    setting.put(SettingBoxKey.defaultPlaySpeed, speed);
    setState(() {
      defaultPlaySpeed = speed;
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        onBackPressed(context);
      },
      child: Scaffold(
        appBar: const SysAppBar(title: Text('播放设置')),
        body: Column(
          children: [
            const InkWell(
              child: SetSwitchItem(
                title: '硬件解码',
                setKey: SettingBoxKey.hAenable,
                defaultVal: true,
              ),
            ),
            const InkWell(
              child: SetSwitchItem(
                title: '低内存模式',
                subTitle: '禁用高级缓存以减少内存占用',
                setKey: SettingBoxKey.lowMemoryMode,
                defaultVal: false,
              ),
            ),
            const InkWell(
              child: SetSwitchItem(
                title: '自动跳转',
                subTitle: '跳转到上次播放位置',
                setKey: SettingBoxKey.playResume,
                defaultVal: true,
              ),
            ),
            ListTile(
              onTap: () async {
                KazumiDialog.show(
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('默认倍速'),
                        content: StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          final List<double> playSpeedList;
                          playSpeedList = defaultPlaySpeedList;
                          return Wrap(
                            spacing: 8,
                            runSpacing: Utils.isDesktop() ? 8 : 0,
                            children: [
                              for (final double i in playSpeedList) ...<Widget>[
                                if (i == defaultPlaySpeed) ...<Widget>[
                                  FilledButton(
                                    onPressed: () async {
                                      updateDefaultPlaySpeed(i);
                                      KazumiDialog.dismiss();
                                    },
                                    child: Text(i.toString()),
                                  ),
                                ] else ...[
                                  FilledButton.tonal(
                                    onPressed: () async {
                                      updateDefaultPlaySpeed(i);
                                      KazumiDialog.dismiss();
                                    },
                                    child: Text(i.toString()),
                                  ),
                                ]
                              ]
                            ],
                          );
                        }),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => KazumiDialog.dismiss(),
                            child: Text(
                              '取消',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              updateDefaultPlaySpeed(1.0);
                              KazumiDialog.dismiss();
                            },
                            child: const Text('默认设置'),
                          ),
                        ],
                      );
                    });
              },
              dense: false,
              title: const Text('默认倍速'),
              subtitle: Text('$defaultPlaySpeed',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: Theme.of(context).colorScheme.outline)),
            ),
          ],
        ),
      ),
    );
  }
}
