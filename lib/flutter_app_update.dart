// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_update/toast.dart';
import 'package:package_info_by_all/package_info_by_all.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FlutterAppUpdate {
  static const MethodChannel _channel =
      const MethodChannel('flutter_app_update');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> checkVersion(
    BuildContext context, {
    String name,
    int code,
    int minCode,
    String content,
    String url,
  }) async {
    var info = await PackageInfo.get();
    int number = int.parse(info.buildNumber);

    if (number < (code ?? 0)) {
      return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return _ShowDialog(
            url: url,
            number: number,
            content: content,
            minCode: minCode,
            name: name,
          );
        },
      );
    }
    return false;
  }

  static Future<bool> installApp(String path) async {
    return await _channel.invokeMethod("installApp", path);
  }
}

class _ShowDialog extends StatefulWidget {
  final String url;

  final int number;

  final int minCode;

  final String content;

  final String name;

  const _ShowDialog({
    Key key,
    this.url,
    this.number,
    this.minCode,
    this.content,
    this.name,
  }) : super(key: key);

  @override
  __ShowDialogState createState() => __ShowDialogState();
}

class __ShowDialogState extends State<_ShowDialog> {
  double _currentProgress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        child: Material(
          color: Color(0x00000000),
          child: Stack(
            children: [
              Image.asset(
                "packages/flutter_app_update/assets/images/bg_update_top.webp",
                height: 140,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
              Container(
                margin: const EdgeInsets.only(top: 138),
                padding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(10)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        '最新版本号 ${widget.name}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          widget.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    if (null != _currentProgress)
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: LinearProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFFF310A)),
                          backgroundColor: Color(0xFFFF8D38),
                          value: _currentProgress,
                          minHeight: 8,
                        ),
                      ),
                    if (null == _currentProgress)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ButtonTheme(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (widget.number >= widget.minCode)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: FlatButton(
                                    child: Text('跳过'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                ),
                              RaisedButton(
                                child: Text(
                                  '更新',
                                  style: TextStyle(color: Colors.white),
                                ),
                                color: Theme.of(context).primaryColor,
                                onPressed: () => _onUpdate(context),
                              ),
                            ],
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _onUpdate(BuildContext context) async {
    try {
      Directory directory = Platform.isWindows
          ? Directory.current
          : await getTemporaryDirectory();
      String savePath = directory.path + "/sports_app_${widget.name}.apk";

      if (Platform.isAndroid) {
        if ((await Permission.storage.status).isUndetermined) {
          if ((await Permission.storage.request()).isUndetermined) {
            showToast(context, "需要同意保存权限!");
            return;
          }
        }
        setState(() {
          _currentProgress = 0;
        });

        await Dio().download(widget.url, savePath,
            onReceiveProgress: (count, total) {
          setState(() {
            _currentProgress = count / total;
          });
        });
        FlutterAppUpdate.installApp(savePath);
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      _currentProgress = null;
      showToast(context, "更新失败，请稍后再试!");
      setState(() {
        _currentProgress = null;
      });
      rethrow;
    }
  }
}
