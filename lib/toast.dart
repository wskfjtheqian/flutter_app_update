import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

showToast(BuildContext context, String msg, {Duration duration}) {
  assert(msg?.isNotEmpty ?? false);
  OverlayEntry overlay;
  overlay = OverlayEntry(builder: (context) {
    return _Toast(
      msg: msg,
      onRemove: overlay.remove,
      duration: duration,
    );
  });

  Overlay.of(context).insert(overlay);
  return overlay;
}

class _Toast extends StatefulWidget {
  final String msg;
  final VoidCallback onRemove;

  final Duration duration;

  const _Toast({
    Key key,
    this.msg,
    this.onRemove,
    this.duration,
  }) : super(key: key);

  @override
  _ToastState createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _controller.addStatusListener(_onStatusListener);
    _controller.addListener(_onListener);
    super.initState();
    Timer(widget.duration ?? Duration(seconds: 2), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onListener);
    _controller.removeStatusListener(_onStatusListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(0, 0.5),
      child: Opacity(
        opacity: 1 - _controller.value,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.9),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          padding: EdgeInsets.all(8),
          child: Material(
            color: Colors.transparent,
            child: Text(
              widget.msg,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  void _onStatusListener(AnimationStatus status) {
    if (AnimationStatus.completed == status) {
      widget.onRemove?.call();
    }
  }

  void _onListener() {
    setState(() {});
  }
}
