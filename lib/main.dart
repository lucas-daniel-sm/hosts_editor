import 'package:flutter/material.dart';
import 'screens/hosts_editor_screen.dart';

void main() => runApp(const HostsEditorApp());

class HostsEditorApp extends StatelessWidget {
  const HostsEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HostsEditorScreen(),
    );
  }
}
