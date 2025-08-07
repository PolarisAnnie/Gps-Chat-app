import 'package:flutter/material.dart';

class LocationSettings extends StatelessWidget {
  final Map<String, dynamic> userData;

  const LocationSettings({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('location_settings_page')));
  }
}
