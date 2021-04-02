import 'dart:ui';

import 'package:flutter/material.dart';

class AppBarCollaps extends StatefulWidget {
  final Widget child;
  const AppBarCollaps({
    Key key,
    @required this.child,
  }) : super(key: key);
  @override
  _AppBarCollapsState createState() => _AppBarCollapsState();
}

class _AppBarCollapsState extends State<AppBarCollaps> {
  ScrollPosition _position;
  bool _visible;
  double _opacity;
  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _removeListener();
    _addListener();
  }
  void _addListener() {
    _position = Scrollable.of(context)?.position;
    _position?.addListener(_positionListener);
    _positionListener();
  }
  void _removeListener() {
    _position?.removeListener(_positionListener);
  }
  void _positionListener() {
    final FlexibleSpaceBarSettings settings =
      context.inheritFromWidgetOfExactType(FlexibleSpaceBarSettings);
    bool visible = settings == null || settings.currentExtent <= settings.minExtent;
    if (_visible != visible) {
      setState(() {
        _visible = visible;
        if(_visible){
          _opacity = 1.0;
        } else {
          _opacity = 0.0;
        }
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: _opacity,
      curve: Curves.fastOutSlowIn,
      child: widget.child,
    );
  }
}