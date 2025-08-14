import 'package:flutter/material.dart';
import 'package:hr_artugo_app/core.dart';
import '../view/debug_view.dart';

class DebugController extends State<DebugView> {
  static late DebugController instance;
  late DebugView view;

  @override
  void initState() {
    instance = this;
    super.initState();
  }

  @override
  void dispose() => super.dispose();

  @override
  Widget build(BuildContext context) => widget.build(context, this);
}
