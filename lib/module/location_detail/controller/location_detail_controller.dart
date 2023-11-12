import 'package:flutter/material.dart';
import '../view/location_detail_view.dart';

class LocationDetailController extends State<LocationDetailView> {
  static late LocationDetailController instance;
  late LocationDetailView view;

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
